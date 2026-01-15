/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
import java.sql.Timestamp;

public class RolePermission {
    private int roleId;
    private int permissionId;

    // optional fields (nếu DB bạn có)
    private Integer grantedBy;
    private Timestamp grantedAt;

    public RolePermission() {}

    public RolePermission(int roleId, int permissionId) {
        this.roleId = roleId;
        this.permissionId = permissionId;
    }

    public RolePermission(int roleId, int permissionId, Integer grantedBy, Timestamp grantedAt) {
        this.roleId = roleId;
        this.permissionId = permissionId;
        this.grantedBy = grantedBy;
        this.grantedAt = grantedAt;
    }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public int getPermissionId() { return permissionId; }
    public void setPermissionId(int permissionId) { this.permissionId = permissionId; }

    public Integer getGrantedBy() { return grantedBy; }
    public void setGrantedBy(Integer grantedBy) { this.grantedBy = grantedBy; }

    public Timestamp getGrantedAt() { return grantedAt; }
    public void setGrantedAt(Timestamp grantedAt) { this.grantedAt = grantedAt; }
}
