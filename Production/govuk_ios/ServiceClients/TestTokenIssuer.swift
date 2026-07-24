import Foundation

class TestTokenIssuer {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: String = "https://xd2oxqfeqb.execute-api.eu-west-2.amazonaws.com",
         session: URLSession = .shared) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid test issuer base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
    }

    func generateToken(authSystemSub: String,
                      completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/v1/token")
        print("🔑 Generating test token for: \(authSystemSub)")
        print("🔑 Token issuer URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["authSystemSub": authSystemSub]
        request.httpBody = try? JSONEncoder().encode(body)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Token generation failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("❌ No token data received")
                completion(.failure(NSError(domain: "TestTokenIssuer",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("❌ Token generation failed with status: \(statusCode)")
                completion(.failure(NSError(domain: "TestTokenIssuer",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("✅ Token generated successfully (length: \(tokenResponse.token.count))")
                completion(.success(tokenResponse.token))
            } catch {
                print("❌ Token decode error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    private struct TokenResponse: Codable {
        let token: String
    }
}
