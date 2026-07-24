import Foundation

class MailboxSetupHelper {
    private let identityResolutionURL: String
    private let clientAccessURL: String
    private let session: URLSession

    init(identityResolutionURL: String = "https://ifu2dhrrpl.execute-api.eu-west-2.amazonaws.com/prod",
         clientAccessURL: String = "https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod",
         session: URLSession = .shared) {
        self.identityResolutionURL = identityResolutionURL
        self.clientAccessURL = clientAccessURL
        self.session = session
    }

    func createMailbox(authSystemSub: String,
                      completion: @escaping (Result<CreateMailboxResponse, Error>) -> Void) {
        guard let url = URL(string: "\(identityResolutionURL)/users") else {
            completion(.failure(NSError(domain: "MailboxSetupHelper",
                                       code: -1,
                                       userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["authSystemSub": authSystemSub]
        request.httpBody = try? JSONEncoder().encode(body)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "MailboxSetupHelper",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let result = try JSONDecoder().decode(CreateMailboxResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func grantConsent(token: String,
                     departmentId: String,
                     departmentPersonId: String,
                     completion: @escaping (Result<GrantConsentResponse, Error>) -> Void) {
        guard let url = URL(string: "\(clientAccessURL)/consents") else {
            completion(.failure(NSError(domain: "MailboxSetupHelper",
                                       code: -1,
                                       userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GrantConsentRequest(
            departmentId: departmentId,
            departmentPersonId: departmentPersonId
        )
        request.httpBody = try? JSONEncoder().encode(body)

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "MailboxSetupHelper",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let result = try JSONDecoder().decode(GrantConsentResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func setupTestUser(authSystemSub: String = "test-citizen-001",
                      niNumber: String = "ST123456A",
                      driverNumber: String = "THOMS801234ST9IJ",
                      taxReference: String = "1234567890",
                      completion: @escaping (Result<String, Error>) -> Void) {
        print("🔧 Setting up test user: \(authSystemSub)")

        createMailbox(authSystemSub: authSystemSub) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                print("✅ Mailbox created: \(response.mailboxId)")

                let tokenIssuer = TestTokenIssuer()
                tokenIssuer.generateToken(authSystemSub: authSystemSub) { tokenResult in
                    switch tokenResult {
                    case .success(let token):
                        let group = DispatchGroup()
                        var errors: [Error] = []

                        let departments = [
                            ("dwp", niNumber),
                            ("dvla", driverNumber),
                            ("hmrc", taxReference)
                        ]

                        for (deptId, personId) in departments {
                            group.enter()
                            self.grantConsent(token: token,
                                            departmentId: deptId,
                                            departmentPersonId: personId) { consentResult in
                                switch consentResult {
                                case .success:
                                    print("✅ Consent granted to \(deptId)")
                                case .failure(let error):
                                    print("❌ Failed to grant consent to \(deptId): \(error)")
                                    errors.append(error)
                                }
                                group.leave()
                            }
                        }

                        group.notify(queue: .main) {
                            if errors.isEmpty {
                                completion(.success(response.mailboxId))
                            } else {
                                completion(.failure(errors.first!))
                            }
                        }

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
