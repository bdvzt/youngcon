import Foundation

enum NetworkLogger {
    static func logRequest(_ request: URLRequest) {
        #if DEBUG
            var parts: [String] = []

            let method = request.httpMethod ?? "UNKNOWN"
            let urlString = request.url?.absoluteString ?? "nil"
            let path = request.url?.path ?? "nil"
            let query = request.url?.query ?? "none"

            parts.append("➡️ REQUEST")
            parts.append("Method: \(method)")
            parts.append("URL: \(urlString)")
            parts.append("Path: \(path)")
            parts.append("Query: \(query)")

            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                parts.append("Headers:")
                headers
                    .sorted(by: { $0.key < $1.key })
                    .forEach { key, value in
                        parts.append("  \(key): \(value)")
                    }
            } else {
                parts.append("Headers: none")
            }

            if let bodyData = request.httpBody, !bodyData.isEmpty {
                parts.append("Body:")
                parts.append(prettyPrintedBody(from: bodyData))
            } else {
                parts.append("Body: none")
            }

            print("\n" + parts.joined(separator: "\n") + "\n")
        #endif
    }

    static func logResponse(
        request: URLRequest,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        duration: TimeInterval
    ) {
        #if DEBUG
            var parts: [String] = []

            let method = request.httpMethod ?? "UNKNOWN"
            let urlString = request.url?.absoluteString ?? "nil"
            let ms = Int(duration * 1000)

            parts.append("⬅️ RESPONSE")
            parts.append("Method: \(method)")
            parts.append("URL: \(urlString)")
            parts.append("Duration: \(ms) ms")

            if let http = response as? HTTPURLResponse {
                parts.append("Status: \(http.statusCode)")

                if !http.allHeaderFields.isEmpty {
                    parts.append("Headers:")
                    http.allHeaderFields
                        .map { ("\($0.key)", "\($0.value)") }
                        .sorted(by: { $0.0 < $1.0 })
                        .forEach { key, value in
                            parts.append("  \(key): \(value)")
                        }
                } else {
                    parts.append("Headers: none")
                }
            } else {
                parts.append("Status: no HTTPURLResponse")
            }

            if let error {
                parts.append("Error: \(error.localizedDescription)")
            }

            if let data, !data.isEmpty {
                parts.append("Body:")
                parts.append(prettyPrintedBody(from: data))
            } else {
                parts.append("Body: none")
            }

            print("\n" + parts.joined(separator: "\n") + "\n")
        #endif
    }

    private static func prettyPrintedBody(from data: Data) -> String {
        guard !data.isEmpty else { return "  <empty>" }

        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8)
        {
            return prettyString
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { "  \($0)" }
                .joined(separator: "\n")
        }

        if let string = String(data: data, encoding: .utf8), !string.isEmpty {
            return string
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { "  \($0)" }
                .joined(separator: "\n")
        }

        return "  <\(data.count) bytes binary data>"
    }
}
