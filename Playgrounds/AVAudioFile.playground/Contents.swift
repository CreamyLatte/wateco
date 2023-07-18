import Cocoa
import AVFAudio

var greeting = "Hello, playground"

let audioFileUrl = #fileLiteral(resourceName: "03_E_はぃぃ....wav")

//let audioFile = try AVAudioFile(forReading: audioFileUrl)
//
//print("url:", audioFile.url.path)
//print("fileFormat:", audioFile.fileFormat)
//print("processingFormat:", audioFile.processingFormat)
//print("length:", audioFile.length)
//
//let audioFormat = audioFile.fileFormat
//let frameLength: AVAudioFrameCount = AVAudioFrameCount(audioFile.length)
//let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameLength)!
//try audioFile.read(into: pcmBuffer)

//let pcmFloatChannelData = pcmBuffer.floatChannelData
//let pcmInt16ChannelData = pcmBuffer.int16ChannelData
//var data: Array<Array<Double>> = []
//
//for i in 0..<audioFile.fileFormat.channelCount {
//    var channelData = Array<Double>()
//    for j in 0..<10000 {
//        channelData.append(Double(pcmFloatChannelData![Int(i)][Int(j)]))
//    }
//    data.append(channelData)
//}
//print(data[0].max() ?? "nil")
func test() throws {
    let readURL = #fileLiteral(resourceName: "04kameda.txt")
    let readData = try Data(contentsOf: readURL)
    let dataValues = [String(data: readData, encoding: .utf8)!.split(separator: "\n").map({ Int16($0)! })]
    let audioLength = dataValues[0].count
    let writingURL = URL(fileURLWithPath: "/Users/creamylatte/Desktop/new.wav")
    
    print(writingURL.path)
    let audioSettings: [String: Any] = [
        "AVFormatIDKey": kAudioFormatLinearPCM,
        "AVSampleRateKey": 44100,
        "AVNumberOfChannelsKey": 1
    ]
    let createAudioFile = try AVAudioFile(forWriting: writingURL, settings: audioSettings, commonFormat: .pcmFormatInt16, interleaved: false)
    print(createAudioFile.fileFormat)
    let writePCMBuffer = AVAudioPCMBuffer(pcmFormat: createAudioFile.fileFormat, frameCapacity: AVAudioFrameCount(audioLength))!
    print(writePCMBuffer.frameLength)
    
    let start = Date()
    
//    for i in 0..<dataValues.count {
//        for j in 0..<dataValues.first!.count {
//            writePCMBuffer.int16ChannelData![i][j] = Int16(dataValues[i][j])
//        }
//
//    }
    for (ch, data) in dataValues.enumerated() {
        writePCMBuffer.int16ChannelData![ch].initialize(from: data, count: audioLength)

    }
    writePCMBuffer.frameLength = AVAudioFrameCount(audioLength)
    
    let elapsed = Date().timeIntervalSince(start)
    print(elapsed)
    
    print(writePCMBuffer.frameLength)
    do {
        try createAudioFile.write(from: writePCMBuffer)
    } catch {
        print(error)
    }
}

try test()

print("finish.")
exit(0)
