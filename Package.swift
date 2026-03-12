// swift-tools-version: 6.0
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Easy Note",
    platforms: [
        .iOS("18.0")
    ],
    products: [
        .iOSApplication(
            name: "Easy Note",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.easy-note",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .note),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [.pad, .phone],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources"
        )
    ]
)
