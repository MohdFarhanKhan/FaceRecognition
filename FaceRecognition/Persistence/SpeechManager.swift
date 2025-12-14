//
//  SpeechManager.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 29/11/25.
//

import SwiftUI
import AVFoundation
import NaturalLanguage
class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var textToSpeech = ""
    private let speechMap:  [String: [String]]
    func speak(_ text: String) {
        let code = bestSpeechCode(for: text)
        print("Code:\(code)")
        let utterance = AVSpeechUtterance(string: textToSpeech)
        utterance.voice = AVSpeechSynthesisVoice(language: code)
        utterance.rate = 0.1
        utterance.volume = 1.0
        
      
        synthesizer.speak(utterance)
    }
    init(){
        var map: [String: [String]] = [:]
        
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            let fullCode = voice.language          // ex: "en-US"
            
            // Get base language code ("en", "hi", "fr", etc.)
            let components = fullCode.split(separator: "-")
            guard let base = components.first else { continue }
            let baseCode = String(base)
            
            // Add full code into list
            if map[baseCode] == nil {
                map[baseCode] = [fullCode]
            } else {
                if !map[baseCode]!.contains(fullCode) {
                    map[baseCode]!.append(fullCode)
                }
            }
        }
        print(map)
        self.speechMap = map
    }
    private func detectBaseLanguageCode(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let lang = recognizer.dominantLanguage {
            return lang.rawValue   // "en", "hi", "ar"
        }
        return "unknown"
    }
 private func bestSpeechCode(for text: String) -> String {
     textToSpeech = text
     let base = detectBaseLanguageCode(from: text) // "en", "hi", etc.
     let code = speechMap[base]?.first ?? ( base == "ur" ? "ar-SA" : "en-US")
     if base == "en"{
         textToSpeech = "Hello \(textToSpeech)"
     }
     else  if base == "hi"{
         textToSpeech = "नमस्कार \(textToSpeech)"
     }
     else{
         textToSpeech = "السلام عليكم \(textToSpeech)"
     }
     print("Language:\(base),  Code: \(code)")
     return code
 }
  
}
