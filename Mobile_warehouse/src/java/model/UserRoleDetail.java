package model;

public class UserRoleDetail {
    private User user;
    private Role role;

    public UserRoleDetail() {}

    public UserRoleDetail(User user, Role role) {
        this.user = user;
        this.role = role;
    }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
}
