/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtil {

    // TODO: điền Gmail gửi + App Password
    private static final String SMTP_USER = "minhduchoang2410@gmail.com";
    private static final String SMTP_APP_PASSWORD = "zjmm itck wdiu qiuj"; // 16 chars

    public static boolean sendOtp(String toEmail, String otp, int minutes) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_APP_PASSWORD);
                }
            });

            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SMTP_USER)); // đơn giản cho khỏi lỗi encoding
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Your OTP Code (WMS)");
            msg.setText(
                    "Your OTP code is: " + otp + "\n\n"
                    + "This code will expire in " + minutes + " minutes.\n"
                    + "If you did not request this, please ignore this email."
            );

            Transport.send(msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
