/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class Role {
    private int roleId;
    private String roleName;
    private String description;
    private int status;     // map is_active
    private int userCount;  // count users

    public Role() {}

    public Role(int roleId, String roleName, String description, int status, int userCount) {
        this.roleId = roleId;
        this.roleName = roleName;
        this.description = description;
        this.status = status;
        this.userCount = userCount;
    }

    public int getRoleId() { return roleId; }
    public String getRoleName() { return roleName; }
    public String getDescription() { return description; }
    public int getStatus() { return status; }
    public int getUserCount() { return userCount; }

    public void setRoleId(int roleId) { this.roleId = roleId; }
    public void setRoleName(String roleName) { this.roleName = roleName; }
    public void setDescription(String description) { this.description = description; }
    public void setStatus(int status) { this.status = status; }
    public void setUserCount(int userCount) { this.userCount = userCount; }
}
