//
//  Recognize.swift
//  computer-vision
//
//  Created by chee on 2022-08-12.
//

import Foundation
import ArgumentParser
import AppKit
import Vision

extension ComputerVision {
    struct Recognize: ParsableCommand {
        static var configuration
            = CommandConfiguration(
                abstract: "Recognize things in a still image.",
                subcommands: [Text.self, Animals.self, PrintAnimalTypes.self, Everything.self])
    }
}

func getImageFromPath(path: String) -> CGImage? {
    return NSImage(contentsOfFile:path)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
}

extension ComputerVision.Recognize {
    struct Text: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Recognize text in a still image")
        
        @Flag(name: [.long], help: "Insert text into FILE's Finder Comments")
        var insert = false
        @Argument(help: "The image for the computer to look at.")
        var path: String
        
        func recognize(request: VNRequest, error: Error?) {
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            // Process the recognized strings.
            for observation in observations {
                let first = observation.topCandidates(1).first
                if (first != nil) {
                    print(first!.string)
                }
            }
        }
        
        mutating func run() throws {
            guard let image = getImageFromPath(path: path) else {return}
            let requestHandler = VNImageRequestHandler(cgImage: image)
            let request = VNRecognizeTextRequest(completionHandler: recognize)
            do {
                // Perform the text-recognition request.
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the requests: \(error).")
            }
        }
    }
    
    struct Animals: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Recognize animals in a still image")
        
        @Flag(name: [.long], help: "Insert text into FILE's Finder Comments")
        var insert = false
        @Argument(help: "The image for the computer to look at.")
        var path: String
        
        func recognize(request: VNRequest, error: Error?) {
            guard let observations =
                    request.results as? [VNRecognizedObjectObservation] else {
                return
            }
            
            for observation in observations {
                for label in observation.labels {
                    let percent = Int(label.confidence * 100)
                    let animal = label.identifier.lowercased()
                    print("\(animal) (\(percent)% sure)")
                }
            }
        }
        
        mutating func run() throws {
            guard let image = getImageFromPath(path: path) else {return}
            let requestHandler = VNImageRequestHandler(cgImage: image)
            let request = VNRecognizeAnimalsRequest(completionHandler: recognize)
            do {
                // Perform the text-recognition request.
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the requests: \(error).")
            }
        }
    }
    
    struct PrintAnimalTypes: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Print out the animals that can be recognized")
        
        mutating func run() throws {
            let request = VNRecognizeAnimalsRequest()
            let identifiers = try request.supportedIdentifiers()
            for animal in identifiers {
                print(animal.rawValue)
            }
        }
    }
    
    struct Everything: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Recognize text and animals in a still image")
        
        @Flag(name: [.long], help: "Insert text into FILE's Finder Comments")
        var insert = false
        @Argument(help: "The image for the computer to look at.")
        var path: String
        
        mutating func run() throws {
            print("not implemented")
        }
    }
}
