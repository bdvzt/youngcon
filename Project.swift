import ProjectDescription

let swiftLintScript: TargetScript = .pre(
    script: """
        if which swiftlint >/dev/null; then
            swiftlint
        else
            echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
        fi
    """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
)

let project = Project(
    name: "YoungCon",
    options: .options(
        defaultKnownRegions: ["ru"],
        developmentRegion: "ru"
    ),
    settings: .settings(
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        .target(
            name: "YoungCon",
            destinations: .iOS,
            product: .app,
            bundleId: "com.bdvzt.YoungCon",
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "YoungCon"
            ]),
            sources: [
                "Sources/**"
            ],
            resources: [
                "Resources/**"
            ],
            scripts: [swiftLintScript],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Kingfisher")
            ]
        )
    ]
)
