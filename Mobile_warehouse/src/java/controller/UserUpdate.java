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

@WebServlet("/admin/user/update")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class UserUpdate extends HttpServlet {

    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
    private String n(String s) { return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id = toInt(req.getParameter("id"), -1);
        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=invalid");
            return;
        }

        UserDAO udao = new UserDAO();
        User u = udao.getById(id);
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?msg=notfound");
            return;
        }

        RoleDAO rdao = new RoleDAO();
        req.setAttribute("user", u);
        req.setAttribute("roles", rdao.searchRoles(null, null));

        req.getRequestDispatcher("/update_user_information.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int userId = toInt(req.getParameter("user_id"), -1);
        int roleId = toInt(req.getParameter("role_id"), -1);

        String fullName = n(req.getParameter("full_name"));
        String email    = n(req.getParameter("email"));
        String phone    = n(req.getParameter("phone"));
        String address  = n(req.getParameter("address"));
        int status      = toInt(req.getParameter("status"), 1);

        if (userId <= 0 || roleId <= 0 || fullName.isEmpty()) {
            req.setAttribute("error", "Invalid input! (Full Name and Role are required)");
            doGet(req, resp);
            return;
        }

        // --- handle avatar upload ---
        String avatarPath = n(req.getParameter("current_avatar")); // giữ avatar cũ
        Part filePart = req.getPart("avatarFile");
        if (filePart != null && filePart.getSize() > 0) {
            String savedPath = saveAvatarToUploads(req, filePart, userId);
            if (savedPath != null) {
                avatarPath = savedPath; // replace
            }
        }

        UserDAO dao = new UserDAO();
        boolean ok = dao.updateUserInfo(userId, fullName, email, phone, roleId, status, avatarPath, address);

        // refresh session authUser nếu update đúng user đang login
        HttpSession session = req.getSession(false);
        if (session != null) {
            User auth = (User) session.getAttribute("authUser");
            if (auth != null && auth.getUserId() == userId) {
                session.setAttribute("authUser", dao.getById(userId));
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users?msg=" + (ok ? "updated" : "failed"));
    }

    private String saveAvatarToUploads(HttpServletRequest req, Part filePart, int userId) throws IOException {
        String submitted = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dot = submitted.lastIndexOf('.');
        if (dot >= 0) ext = submitted.substring(dot).toLowerCase();

        if (!(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp"))) {
            return null;
        }

        String fileName = "u_" + userId + "_" + System.currentTimeMillis() + ext;

        String uploadDir = req.getServletContext().getRealPath("/uploads/avatars");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        File saved = new File(dir, fileName);
        try (InputStream in = filePart.getInputStream(); FileOutputStream out = new FileOutputStream(saved)) {
            in.transferTo(out);
        }

        // DB lưu relative path
        return "uploads/avatars/" + fileName;
    }
}
