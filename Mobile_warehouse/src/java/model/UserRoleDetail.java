/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class UserRoleDetail {
    private int userId;
    private String username;
    private int roleId;
    private String roleName;
    private String fullName;

    private int status;

    public UserRoleDetail() {}


    public UserRoleDetail(int userId, String username, int roleId, String roleName, String fullName, int status) {
        this.userId = userId;
        this.username = username;
        this.roleId = roleId;
        this.roleName = roleName;
        this.fullName = fullName;
        this.status = status;
    }

   
    public UserRoleDetail(int userId, String username, int roleId, String roleName, String fullName) {
        this(userId, username, roleId, roleName, fullName, 1);
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

   
    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }
}