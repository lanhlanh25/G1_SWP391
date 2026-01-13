/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.sql.Timestamp;

/**
 *
 * @author Admin
 */
public class RolePermission {
    private int roleId;
    private int permissionId;
    private Timestamp grantedAt;
    private Integer grantedBy;
    
    private String roleName;
    private String permissionCode;
    private String permissionName;

    public RolePermission() {
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public int getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(int permissionId) {
        this.permissionId = permissionId;
    }

    public Timestamp getGrantedAt() {
        return grantedAt;
    }

    public void setGrantedAt(Timestamp grantedAt) {
        this.grantedAt = grantedAt;
    }

    public Integer getGrantedBy() {
        return grantedBy;
    }

    public void setGrantedBy(Integer grantedBy) {
        this.grantedBy = grantedBy;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getPermissionCode() {
        return permissionCode;
    }

    public void setPermissionCode(String permissionCode) {
        this.permissionCode = permissionCode;
    }

    public String getPermissionName() {
        return permissionName;
    }

    public void setPermissionName(String permissionName) {
        this.permissionName = permissionName;
    }
    
    
}
