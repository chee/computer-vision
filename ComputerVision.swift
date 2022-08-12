import Foundation
import ArgumentParser

@main
struct ComputerVision: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Interface to Apple's Vision APIs",
        subcommands: [Recognize.self]
    )
}
