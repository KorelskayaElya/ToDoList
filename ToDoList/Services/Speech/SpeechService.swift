//
//  SpeechService.swift
//  ToDoList
//
//  Created by Эля Корельская on 08.08.2025.
//

import Foundation
import Speech
import AVFoundation

// MARK: - Delegate

/// Протокол обратной связи для сервиса распознавания речи.
protocol SpeechServiceDelegate: AnyObject {
    /// Вызывается при обновлении распознанного текста (частичные и финальные результаты)
    /// - Parameters:
    ///   - service: Экземпляр `SpeechService`
    ///   - text: Текущий распознанный текст (накопительный в рамках одной сессии задачи)
    func speechService(_ service: SpeechService, didUpdate text: String)

    /// Вызывается при «нормальном» завершении сессии прослушивания (по `stop()` или при недоступности сервиса)
    /// - Parameter service: Экземпляр `SpeechService`
    func speechServiceDidFinish(_ service: SpeechService)

    /// Вызывается при ошибке во время работы распознавания речи (кроме ожидаемых отмен при перезапуске/стопе)
    /// - Parameters:
    ///   - service: Экземпляр `SpeechService`
    ///   - error: Объект ошибки
    func speechService(_ service: SpeechService, didFail error: Error)
}

// MARK: - Service

/// Сервис непрерывного распознавания речи c лупом
final class SpeechService: NSObject {

    // MARK: - Public

    weak var delegate: SpeechServiceDelegate?
    var isListening: Bool { audioEngine.isRunning }

    // MARK: - Configuration

    private(set) var locale: Locale
    private let loopInterval: TimeInterval
    private let forceOnDevice: Bool

    // MARK: - Speech internals

    private let recognizer: SFSpeechRecognizer
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var loopTimer: Timer?
    private var isUserStopping = false

    // MARK: - Init

    /// Инициализация сервиса распознавания речи.
    /// - Parameters:
    ///   - locale: Язык распознавания (по умолчанию `ru-RU`)
    ///   - loopInterval: Интервал перезапуска задачи распознавания (5 сек)
    ///   - forceOnDevice: Принудительно ли требовать оффлайн-распознавание (по умолчанию `false`)
    init(
        locale: Locale = Locale(identifier: "ru-RU"),
        loopInterval: TimeInterval = 5.0,
        forceOnDevice: Bool = false
    ) {
        self.locale = locale
        self.loopInterval = loopInterval
        self.forceOnDevice = forceOnDevice
        guard let createdRecognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(
            locale: Locale(identifier: "ru-RU")
        ) else {
            fatalError(
                "[SpeechService] Не удалось создать SFSpeechRecognizer"
            )
        }
        self.recognizer = createdRecognizer
        super.init()
        self.recognizer.delegate = self
    }

    // MARK: - Permissions

    /// Запрашивает разрешения на использование распознавания речи и микрофона
    ///
    /// - Parameter completion: Замыкание с результатом: `true` — доступ есть, `false` — доступ запрещён
    func prepareAuthorization(completion: ((Bool) -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { status in
            AVAudioSession.sharedInstance().requestRecordPermission {
                micGranted in
                let granted = (status == .authorized) && micGranted
                DispatchQueue.main.async { completion?(granted) }
            }
        }
    }

    // MARK: - Control
    
    /// Запускает прослушивание и распознавание речи
    ///
    /// Если доступа к микрофону/распознаванию нет — дернёт делегат `didFail`
    /// Если сервис уже запущен — повторный старт игнорируется
    func start() {
    #if targetEnvironment(simulator)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.speechService(self, didFail: NSError(
                domain: "SpeechService",
                code: -1000,
                userInfo: [NSLocalizedDescriptionKey: "Распознавание речи недоступно в симуляторе"]
            ))
        }
    #else
        guard !audioEngine.isRunning else { return }
        isUserStopping = false

        let st = SFSpeechRecognizer.authorizationStatus()
        print("[Speech] authStatus = \(st.rawValue)")
        print("[Speech] recognizer.isAvailable = \(recognizer.isAvailable)")
        if #available(iOS 13.0, *) {
            print("[Speech] supportsOnDevice = \(recognizer.supportsOnDeviceRecognition)")
        }

        prepareAuthorization { [weak self] granted in
            guard let self = self else { return }
            guard granted else {
                self.delegate?.speechService(
                    self,
                    didFail: NSError(
                        domain: "SpeechService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Нет доступа к микрофону/распознаванию речи"]
                    )
                )
                return
            }
            self.beginRecognition()
            self.setLoopTimer(enabled: true)
        }
    #endif
    }

    /// Останавливает прослушивание и завершает текущую сессию
    ///
    /// Вызывает `speechServiceDidFinish(_:)` у делегата после корректного завершения
    func stop() {
        isUserStopping = true
        setLoopTimer(enabled: false)

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        request?.endAudio()
        task?.cancel()
        task = nil

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.speechServiceDidFinish(self)
        }
    }
}

// MARK: - Private

private extension SpeechService {

    /// Включает/выключает луп перезапуска задачи распознавания.
    func setLoopTimer(enabled: Bool) {
        loopTimer?.invalidate()
        loopTimer = nil
        guard enabled else { return }
        let timer = Timer.scheduledTimer(
            withTimeInterval: loopInterval,
            repeats: true
        ) { [weak self] _ in
            self?.softRestartRecognitionTask()
        }
        RunLoop.main.add(timer, forMode: .common)
        loopTimer = timer
    }

    /// рестарт recognition-задачи (без остановки всей аудиосессии)
    ///
    /// Снимаем tap, закрываем текущий request/task и запускаем новую задачу на том же аудиодвижке
    func softRestartRecognitionTask() {
        if isUserStopping { return }

        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        startNewRecognitionTaskOnActiveEngine()
    }

    /// Конфигурация аудиосессии и запуск первой recognition-задачи
    func beginRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)

        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil

        guard recognizer.isAvailable else {
            delegate?.speechService(
                self,
                didFail: NSError(
                    domain: "SpeechService",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Сервис распознавания временно недоступен"
                    ]
                )
            )
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [
                    .duckOthers,
                        .defaultToSpeaker
                ]
            )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            delegate?.speechService(self, didFail: error)
            return
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            delegate?.speechService(self, didFail: error)
            return
        }
        startNewRecognitionTaskOnActiveEngine()
    }

    /// Определяет, является ли переданная ошибка ожидаемым событием "отмены" распознавания речи
    /// - Parameter err: Объект ошибки `NSError`, который требуется проверить
    /// - Returns: `true`, если ошибка является ожидаемой отменой и не должна обрабатываться как сбой
    private func isExpectedCancel(_ err: NSError) -> Bool {
        if isUserStopping { return true }
        let domain = err.domain
        // iOS 17+: SFSpeechErrorDomain / 203 (canceled)
        if domain == "SFSpeechErrorDomain", err.code == 203 { return true }
        // iOS 15–16: Siri Assistant domain
        if domain == "kAFAssistantErrorDomain", (err.code == 1101 || err.code == 1110) { return true }
        if domain == NSURLErrorDomain, err.code == NSURLErrorCancelled { return true }
        return false
    }

    /// Запускает новую recognition-задачу, предполагая, что `audioEngine` уже активен
    func startNewRecognitionTaskOnActiveEngine() {
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            req.taskHint = .search
            req.requiresOnDeviceRecognition = forceOnDevice
        }
        self.request = req
        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) {
            [weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        task = recognizer.recognitionTask(with: req) {
            [weak self] result, error in
            guard let self = self else { return }
            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.delegate?.speechService(self, didUpdate: text)
                }
            }
            if let err = error as NSError? {
                let expected = self.isExpectedCancel(err)
                if !expected {
                    DispatchQueue.main.async {
                        self.delegate?.speechService(
                            self,
                            didFail: err)
                    }
                }

                if !self.isUserStopping, self.audioEngine.isRunning {
                    self.softRestartRecognitionTask()
                } else {
                    DispatchQueue.main.async { self.stop() }
                }
            }
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension SpeechService: SFSpeechRecognizerDelegate {
    /// Вызывается при изменении доступности сервиса распознавания речи.
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            stop()
        }
    }
}
