/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.Paths;
import model.User;

@WebServlet("/upload-avatar")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class UploadAvatarServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        // take login user
        HttpSession session = req.getSession(false);
        User auth = (session == null) ? null : (User) session.getAttribute("authUser");
        if (auth == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Part filePart = req.getPart("avatarFile");
        if (filePart == null || filePart.getSize() == 0) {
            resp.sendRedirect(req.getContextPath() + "/home?p=my-profile&msg=nofile");
            return;
        }

        // validate extension nhanh 
        String submitted = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dot = submitted.lastIndexOf('.');
        if (dot >= 0) ext = submitted.substring(dot).toLowerCase();

        if (!(ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp"))) {
            resp.sendRedirect(req.getContextPath() + "/home?p=my-profile&msg=badtype");
            return;
        }

        // rename file
        String fileName = "u_" + auth.getUserId() + "_" + System.currentTimeMillis() + ext;

        // save in web/uploads/avatars
        String uploadDir = getServletContext().getRealPath("/uploads/avatars");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        File saved = new File(dir, fileName);

        try (InputStream in = filePart.getInputStream();
             FileOutputStream out = new FileOutputStream(saved)) {
            in.transferTo(out);
        }

        // path store in DB (relative path)
        String dbPath = "uploads/avatars/" + fileName;

        UserDAO dao = new UserDAO();
        boolean ok = dao.updateAvatarPath(auth.getUserId(), dbPath);

        if (!ok) {
            saved.delete();
            resp.sendRedirect(req.getContextPath() + "/home?p=my-profile&msg=dbfail");
            return;
        }

        // update session để khỏi phải logout/login
        auth.setAvatar(dbPath);
        session.setAttribute("authUser", auth);

        resp.sendRedirect(req.getContextPath() + "/home?p=my-profile&msg=avatar_updated");
    }
}
