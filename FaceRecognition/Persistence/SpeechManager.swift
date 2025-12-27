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
    private let isGuidance: Bool
    func speak(_ text: String) {
        let code = bestSpeechCode(for: text)
        print("Code:\(code)")
        let utterance = AVSpeechUtterance(string: textToSpeech)
        utterance.voice = AVSpeechSynthesisVoice(language: code)
        utterance.rate = 0.1
        utterance.volume = 1.0
        
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    init(isGuidance: Bool){
        self.isGuidance = isGuidance
        var map: [String: [String]] = [:]
       
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            let fullCode = voice.language
            
            // Get base language code ("en", "hi", "fr", etc.)
            let components = fullCode.split(separator: "-")
            guard let base = components.first else { continue }
            let baseCode = String(base)
            if map[baseCode] == nil {
                map[baseCode] = [fullCode]
            } else {
                if !map[baseCode]!.contains(fullCode) {
                    map[baseCode]!.append(fullCode)
                }
            }
        }
      
        self.speechMap = map
        print("Map Code : \(self.speechMap)")
       
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
     let base = detectBaseLanguageCode(from: text)
     let code = speechMap[base]?.first ?? ( base == "ur" ? "ar-SA" : "en-US")
     var greet = ""
     if !self.isGuidance{
         if base == "en"{
             greet = "Hello"
         }
         else  if base == "hi"{
             greet = "नमस्कार"
         }
         else{
             greet = "السلام عليكم"
         }
     }
     textToSpeech = "\(greet), \(textToSpeech)"
     print("Language:\(base),  Code: \(code)")
     return code
 }
    func getMentionToAddMoreFaces(for text: String) -> String {
        
        let base = detectBaseLanguageCode(from: text)
        let code = speechMap[base]?.first ?? ( base == "ur" ? "ar-SA" : "en-US")
        var greet = ""
        if !self.isGuidance{
            if base == "en"{
                greet = " Please mention to add more faces to recognise you correctly "
            }
            else  if base == "hi"{
                greet = "कृपया यह बताएं कि आपको सही ढंग से पहचानने के लिए और भी चेहरे जोड़े जाएं"
            }
            else{
                greet = "آپ کو صحیح طریقے سے پہچاننے کے لیے براہ کرم مزید چہرے شامل کرنے کا ذکر کریں"
            }
        }
       let text = "\(greet), \(text)"
        print("Language:\(base),  Code: \(code)")
        return text
    }
    func getNoMatchText(for text: String) -> String {
        
        let base = detectBaseLanguageCode(from: text)
        let code = speechMap[base]?.first ?? ( base == "ur" ? "ar-SA" : "en-US")
        var greet = ""
        if !self.isGuidance{
            if base == "en"{
                greet = " Please mention to add more faces to recognise you correctly "
            }
            else  if base == "hi"{
                greet = "कृपया यह बताएं कि आपको सही ढंग से पहचानने के लिए और भी चेहरे जोड़े जाएं"
            }
            else{
                greet = "آپ کو صحیح طریقے سے پہچاننے کے لیے براہ کرم مزید چہرے شامل کرنے کا ذکر کریں"
            }
        }
        let text = "\(greet), \(text)"
        print("Language:\(base),  Code: \(code)")
        return text
    }
}
