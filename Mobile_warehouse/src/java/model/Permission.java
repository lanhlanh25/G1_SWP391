/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Admin
 */
public class Permission {
    private int permissionId;
    private String code;
    private String name;
    private String module;
    private String description;
    private int isActive;

    public Permission(int permissionId, String code, String name, String module, String description, int isActive) {
        this.permissionId = permissionId;
        this.code = code;
        this.name = name;
        this.module = module;
        this.description = description;
        this.isActive = isActive;
    }

    public int getPermissionId() { return permissionId; }
    public String getCode() { return code; }
    public String getName() { return name; }
    public String getModule() { return module; }
    public String getDescription() { return description; }
    public int getIsActive() { return isActive; }
}