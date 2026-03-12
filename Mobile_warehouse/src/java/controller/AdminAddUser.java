/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author Admin
 */

import dal.RoleDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.Paths;
import model.User;
import util.PasswordUtil;

@WebServlet(name = "AdminAddUserServlet", urlPatterns = {"/admin/user-add"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class AdminAddUser extends HttpServlet {

    private String n(String s) {
        return s == null ? "" : s.trim();
    }

    private int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Redirect về home controller để có layout đầy đủ
        resp.sendRedirect(req.getContextPath() + "/home?p=user-add");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = n(req.getParameter("username"));
        String password = n(req.getParameter("password"));
        String fullName = n(req.getParameter("full_name"));
        String email    = n(req.getParameter("email"));
        String phone    = n(req.getParameter("phone"));
        String address  = n(req.getParameter("address"));
        int roleId      = parseInt(req.getParameter("role_id"), 0);

        // Validation - dùng session flash để truyền lỗi về home controller
        HttpSession session = req.getSession();

        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || roleId <= 0) {
            // Flash lỗi vào session rồi redirect về home?p=user-add
            session.setAttribute("flash_error",   "Required!!");
            session.setAttribute("flash_v_username",  username);
            session.setAttribute("flash_v_full_name", fullName);
            session.setAttribute("flash_v_email",     email);
            session.setAttribute("flash_v_phone",     phone);
            session.setAttribute("flash_v_address",   address);
            session.setAttribute("flash_v_role_id",   roleId);
            resp.sendRedirect(req.getContextPath() + "/home?p=user-add");
            return;
        }

        UserDAO dao = new UserDAO();
        if (dao.getUserByUsername(username) != null) {
            session.setAttribute("flash_errorU",      "Username already exists!");
            session.setAttribute("flash_v_username",  username);
            session.setAttribute("flash_v_full_name", fullName);
            session.setAttribute("flash_v_email",     email);
            session.setAttribute("flash_v_phone",     phone);
            session.setAttribute("flash_v_address",   address);
            session.setAttribute("flash_v_role_id",   roleId);
            resp.sendRedirect(req.getContextPath() + "/home?p=user-add");
            return;
        }
        if (!email.isEmpty() && dao.getUserByEmail(email) != null) {
            session.setAttribute("flash_errorE",      "Email already exists!");
            session.setAttribute("flash_v_username",  username);
            session.setAttribute("flash_v_full_name", fullName);
            session.setAttribute("flash_v_email",     email);
            session.setAttribute("flash_v_phone",     phone);
            session.setAttribute("flash_v_address",   address);
            session.setAttribute("flash_v_role_id",   roleId);
            resp.sendRedirect(req.getContextPath() + "/home?p=user-add");
            return;
        }

        String avatarPath = "";
        Part filePart = req.getPart("avatarFile");
        if (filePart != null && filePart.getSize() > 0) {
            String saved = saveAvatarToUploads(req, filePart, username);
            if (saved != null) {
                avatarPath = saved;
            }
        }

        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(PasswordUtil.hashPassword(password));
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setRoleId(roleId);
        u.setStatus(1);
        u.setAvatar(avatarPath);
        u.setAddress(address);

        boolean ok = dao.createUser(u);
        if (!ok) {
            session.setAttribute("flash_error", "Create user failed!");
            session.setAttribute("flash_v_username",  username);
            session.setAttribute("flash_v_full_name", fullName);
            session.setAttribute("flash_v_email",     email);
            session.setAttribute("flash_v_phone",     phone);
            session.setAttribute("flash_v_address",   address);
            session.setAttribute("flash_v_role_id",   roleId);
            resp.sendRedirect(req.getContextPath() + "/home?p=user-add");
            return;
        }

        // ✅ Redirect về home controller với layout đầy đủ
        resp.sendRedirect(req.getContextPath() + "/home?p=user-list&msg=User+created+successfully");
    }

    private String saveAvatarToUploads(HttpServletRequest req, Part filePart, String username) throws IOException {
        String submitted = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dot = submitted.lastIndexOf('.');
        if (dot >= 0) {
            ext = submitted.substring(dot).toLowerCase();
        }

        if (!(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp"))) {
            return null;
        }

        String safeUser = username.replaceAll("[^a-zA-Z0-9_\\-]", "_");
        String fileName = "u_" + safeUser + "_" + System.currentTimeMillis() + ext;

        String uploadDir = req.getServletContext().getRealPath("/uploads/avatars");
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File saved = new File(dir, fileName);
        try (InputStream in = filePart.getInputStream(); FileOutputStream out = new FileOutputStream(saved)) {
            in.transferTo(out);
        }

        return "uploads/avatars/" + fileName;
    }
}

