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
                "CFBundleDisplayName": "YoungCon",
                "UIAppFonts": [
                    "Yandex_Sans/fonts/YandexSansDisplay-Bold.ttf",
                    "Yandex_Sans/fonts/YandexSansDisplay-Light.ttf",
                    "Yandex_Sans/fonts/YandexSansDisplay-Regular.ttf",
                    "Yandex_Sans/fonts/YandexSansDisplay-RegularItalic.ttf",
                    "Yandex_Sans/fonts/YandexSansDisplay-Thin.ttf",
                    "Yandex_Sans/fonts/YandexSansText-Bold.ttf",
                    "Yandex_Sans/fonts/YandexSansText-Light.ttf",
                    "Yandex_Sans/fonts/YandexSansText-Medium.ttf",
                    "Yandex_Sans/fonts/YandexSansText-Regular.ttf",
                    "Yandex_Sans/fonts/YandexSansText-RegularItalic.ttf",
                    "Yandex_Sans/fonts/YandexSansText-Thin.ttf"
                ]
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            scripts: [swiftLintScript],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Kingfisher")
            ]
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
    ],

    schemes: [
        .scheme(
            name: "YoungCon",
            buildAction: .buildAction(
                targets: ["YoungCon", "YoungConTests", "YoungConUITests"]
            ),
            testAction: .targets(
                [
                    .testableTarget(target: "YoungConTests"),
                    .testableTarget(target: "YoungConUITests")
                ],
                configuration: "Debug"
            ),
            runAction: .runAction(
                configuration: "Debug",
                executable: "YoungCon"
            )
        )
    ]
)
