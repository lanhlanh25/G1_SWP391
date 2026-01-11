/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author Admin
 */
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {
     private static final int SALT_LENGTH = 16;      // 16 bytes
    private static final int ITERATIONS = 65536;    // số vòng lặp
    private static final int KEY_LENGTH = 256;      // bits

    // Hash password -> trả về "salt:hash" (Base64)
    public static String hashPassword(String password) {
        try {
            byte[] salt = new byte[SALT_LENGTH];
            new SecureRandom().nextBytes(salt);

            byte[] hash = pbkdf2(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);

            String saltB64 = Base64.getEncoder().encodeToString(salt);
            String hashB64 = Base64.getEncoder().encodeToString(hash);

            return saltB64 + ":" + hashB64;
        } catch (Exception e) {
            throw new RuntimeException("Hash password failed", e);
        }
    }

    // Verify password với storedHash
    // - Nếu storedHash có dạng "salt:hash" => verify PBKDF2
    // - Nếu không có ":" => coi như plain text (để compatible lúc dev)
    public static boolean verifyPassword(String inputPassword, String storedHash) {
        try {
            if (storedHash == null) return false;

            // Compatible plain text
            if (!storedHash.contains(":")) {
                return inputPassword.equals(storedHash);
            }

            String[] parts = storedHash.split(":");
            if (parts.length != 2) return false;

            byte[] salt = Base64.getDecoder().decode(parts[0]);
            byte[] expectedHash = Base64.getDecoder().decode(parts[1]);

            byte[] actualHash = pbkdf2(inputPassword.toCharArray(), salt, ITERATIONS, KEY_LENGTH);

            return constantTimeEquals(expectedHash, actualHash);
        } catch (Exception e) {
            return false;
        }
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) throws Exception {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
        SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        return skf.generateSecret(spec).getEncoded();
    }

    // So sánh constant-time để tránh timing attack
    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a == null || b == null) return false;
        if (a.length != b.length) return false;
        int result = 0;
        for (int i = 0; i < a.length; i++) {
            result |= a[i] ^ b[i];
        }
        return result == 0;
    }
}
