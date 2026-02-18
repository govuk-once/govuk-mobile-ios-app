import Foundation
import CryptoKit

public typealias NetworkResult<T> = Result<T, Error>
public typealias NetworkResultCompletion<T> = (NetworkResult<T>) -> Void

protocol APIServiceClientInterface {
    func send(
        request: GOVRequest,
        completion: @escaping NetworkResultCompletion<Data>
    )
}

enum SigningError: Error {
    case invalidSignature
}

struct APIServiceClient: APIServiceClientInterface {
    private let baseUrl: URL
    private let session: URLSession
    private let requestBuilder: RequestBuilderInterface
    private let responseHandler: ResponseHandler?
    private let tokenProvider: TokenProviding?

    init(baseUrl: URL,
         session: URLSession,
         requestBuilder: RequestBuilderInterface,
         responseHandler: ResponseHandler? = nil,
         tokenProvider: TokenProviding? = nil) {
        self.baseUrl = baseUrl
        self.session = session
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
        self.tokenProvider = tokenProvider
    }
}

extension APIServiceClient {
    func send(request: GOVRequest,
              completion: @escaping NetworkResultCompletion<Data>) {
        let urlRequest = requestBuilder.data(
            from: request,
            with: baseUrl
        )
        send(
            request: urlRequest,
            signingKey: request.signingKey,
            requiresAuthentication: request.requiresAuthentication,
            isRetry: false,
            completion: completion
        )
    }

    private func send(request: URLRequest,
                      signingKey: String?,
                      requiresAuthentication: Bool,
                      isRetry: Bool,
                      completion: @escaping NetworkResultCompletion<Data>) {
        var request = request
        if requiresAuthentication, let accessToken = tokenProvider?.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let task = session.dataTask(
            with: request,
            completionHandler: { data, response, error in
                if shouldRefreshTokenAndRetry(response: response, isRetry: isRetry),
                   let tokenProvider = tokenProvider {
                    handleUnauthorizedResponse(request: request,
                                               signingKey: signingKey,
                                               requiresAuthentication: requiresAuthentication,
                                               tokenProvider: tokenProvider,
                                               completion: completion)
                    return
                }

                let localError = responseHandler?.handleResponse(response,
                                                                 error: error) ?? error
                let result: NetworkResult<Data>
                switch (data, localError) {
                case (_, .some(let error)):
                    result = .failure(error)
                case (.some(let data), _):
                       if verifySignatureIfNecessary(
                            signatureBase64: response?.signature,
                            data: data,
                            signingKey: signingKey
                        ) {
                        result = .success(data)
                    } else {
                        result = .failure(SigningError.invalidSignature)
                    }
                case (.none, _):
                    result = .success(Data())
                }
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        )
        task.resume()
    }

    private func shouldRefreshTokenAndRetry(response: URLResponse?, isRetry: Bool) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        return [401, 403].contains(httpResponse.statusCode) && isRetry == false
    }

    private func handleUnauthorizedResponse(request: URLRequest,
                                            signingKey: String?,
                                            requiresAuthentication: Bool,
                                            tokenProvider: TokenProviding,
                                            completion: @escaping NetworkResultCompletion<Data>) {
        Task {
            let result = await tokenProvider.tokenRefreshRequest()
            switch result {
            case .success:
                send(
                    request: request,
                    signingKey: signingKey,
                    requiresAuthentication: requiresAuthentication,
                    isRetry: true,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func verifySignatureIfNecessary(signatureBase64: String?,
                                            data: Data,
                                            signingKey: String?) -> Bool {
        // If no key provided, request doesn't need signing
        guard let signingKey
        else {
            return true
        }

        guard let signatureBase64,
              let signatureData = Data(base64Encoded: signatureBase64)
        else {
            return false
        }

        guard let publicKeyFile = Bundle.main.publicKey(name: signingKey),
              let publicKey = try? P256.Signing.PublicKey(derRepresentation: publicKeyFile)
        else {
            return false
        }

        guard let signatureKey = try? P256.Signing.ECDSASignature(derRepresentation: signatureData)
        else {
            return false
        }

        return publicKey.isValidSignature(signatureKey, for: data)
    }
}
