/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.security.SecureRandom;
import java.util.Properties;

public class EmailUtil {

    private static final String SMTP_USER = "minhduchoang2410@gmail.com";
    private static final String SMTP_APP_PASSWORD = "zjmm itck wdiu qiuj"; 

    private static Session newSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_APP_PASSWORD);
            }
        });
    }

  
    public static boolean sendText(String toEmail, String subject, String content) {
        try {
            Session session = newSession();
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SMTP_USER));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setText(content);

            Transport.send(msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace(); 
            return false;
        }
    }

    public static boolean notifyAdminNewResetRequest(String adminEmail, String userEmail, String userName) {
        String subject = "[WMS] New password reset request";
        String content
                = "A user requested to reset password:\n"
                + "- Name: " + userName + "\n"
                + "- Email: " + userEmail + "\n\n"
                + "Please login to WMS and review the request.";
        return sendText(adminEmail, subject, content);
    }

   
    public static boolean sendRejectToUser(String userEmail, String userName, String reason) {
        String subject = "[WMS] Password reset request rejected";
        String content
                = "Hello " + userName + ",\n\n"
                + "Your password reset request was rejected.\n"
                + "Reason: " + (reason == null || reason.isBlank() ? "(No reason provided)" : reason) + "\n\n"
                + "If you believe this is a mistake, please contact administrator.";
        return sendText(userEmail, subject, content);
    }

    
    public static String randomPassword8() {
        SecureRandom r = new SecureRandom();
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt(r.nextInt(chars.length())));
        }
        return sb.toString();
    }


    public static boolean sendApprovePasswordToUser(String userEmail, String userName, String newPassword) {
        String subject = "[WMS] Password reset approved - Your new password";
        String content
                = "Hello " + userName + ",\n\n"
                + "Your password reset request has been approved.\n"
                + "Your new password is: " + newPassword + "\n\n"
                + "Please login using this password and change it immediately in Change Password.\n"
                + "If you did not request this, please contact administrator.";
        return sendText(userEmail, subject, content);
    }

}
