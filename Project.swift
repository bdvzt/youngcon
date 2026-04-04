import ProjectDescription

let swiftFormatScript: TargetScript = .pre(
    script: """
        export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        if command -v swiftformat >/dev/null; then
            swiftformat .
        else
            echo "warning: SwiftFormat not installed"
        fi
    """,
    name: "SwiftFormat",
    basedOnDependencyAnalysis: false
)

let swiftLintScript: TargetScript = .pre(
    script: """
        export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        if command -v swiftlint >/dev/null; then
            swiftlint
        else
            echo "warning: SwiftLint not installed"
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
            infoPlist: .file(path: "SupportingFiles/Info.plist"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [swiftFormatScript, swiftLintScript],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Kingfisher")
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentPurple"
                ]
            )
        ),

        .target(
            name: "YoungConTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.bdvzt.YoungConTests",
            sources: ["YoungConTests/**"],
            dependencies: [
                .target(name: "YoungCon")
            ]
        ),

        .target(
            name: "YoungConUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.bdvzt.YoungConUITests",
            sources: ["YoungConUITests/**"],
            dependencies: [
                .target(name: "YoungCon")
            ]
        )
    ]
)
