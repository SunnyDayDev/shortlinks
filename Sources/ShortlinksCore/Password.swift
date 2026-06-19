import Foundation
import CryptoKit

/// Хеширование пароля ссылки: соль + SHA-256. Открытый пароль не хранится.
public enum Password {
    /// Возвращает строку формата `"<salt>:<hex sha256(salt+password)>"`.
    public static func hash(_ password: String, salt: String = UUID().uuidString) -> String {
        let digest = SHA256.hash(data: Data((salt + password).utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return "\(salt):\(hex)"
    }

    /// Проверяет пароль против сохранённого хеша.
    public static func verify(_ password: String, against stored: String) -> Bool {
        let parts = stored.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }
        return hash(password, salt: String(parts[0])) == stored
    }
}
