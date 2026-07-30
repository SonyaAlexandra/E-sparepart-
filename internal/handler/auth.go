package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/sessions"

	"sparepart-mgmt/internal/repository"
	"sparepart-mgmt/internal/service"
)

var Store *sessions.CookieStore

const sessionName = "sp-session"

func ShowLogin(c *gin.Context) {
	session, _ := Store.Get(c.Request, sessionName)
	if session.Values["user_id"] != nil {
		if role, _ := session.Values["user_role"].(string); role == "pemohon" {
			c.Redirect(http.StatusFound, "/stok")
		} else {
			c.Redirect(http.StatusFound, "/dashboard")
		}
		return
	}
	renderStandalone(c, "auth/login.html", gin.H{
		"Title": "Login - Sparepart Management",
	})
}

func DoLogin(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	user, err := service.Login(username, password)
	if err != nil {
		renderStandalone(c, "auth/login.html", gin.H{
			"Title": "Login - Sparepart Management",
			"Error": err.Error(),
		})
		return
	}

	session, _ := Store.Get(c.Request, sessionName)
	session.Values["user_id"] = user.ID
	session.Values["user_role"] = user.Role
	session.Values["user_name"] = user.FullName
	session.Values["user_division"] = user.Division
	session.Save(c.Request, c.Writer)

	if user.Role == "pemohon" {
		c.Redirect(http.StatusFound, "/stok")
	} else {
		c.Redirect(http.StatusFound, "/dashboard")
	}
}

func DoLogout(c *gin.Context) {
	session, _ := Store.Get(c.Request, sessionName)
	session.Values = make(map[interface{}]interface{})
	session.Options.MaxAge = -1
	session.Save(c.Request, c.Writer)
	c.Redirect(http.StatusFound, "/login")
}

func RequireAuth(c *gin.Context) {
	session, _ := Store.Get(c.Request, sessionName)
	if session.Values["user_id"] == nil {
		c.Redirect(http.StatusFound, "/login")
		c.Abort()
		return
	}
	c.Next()
}

func RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		session, _ := Store.Get(c.Request, sessionName)
		userRole, ok := session.Values["user_role"].(string)
		if !ok {
			c.Redirect(http.StatusFound, "/login")
			c.Abort()
			return
		}
		// Check if userRole matches any of the allowed roles
		for _, r := range roles {
			if userRole == r {
				c.Next()
				return
			}
		}
		c.Status(http.StatusForbidden)
		renderStandalone(c, "auth/forbidden.html", gin.H{
			"Title": "Akses Ditolak",
		})
		c.Abort()
	}
}

func GetSessionUser(c *gin.Context) (int, string, string, string) {
	session, _ := Store.Get(c.Request, sessionName)
	id, _ := session.Values["user_id"].(int)
	role, _ := session.Values["user_role"].(string)
	name, _ := session.Values["user_name"].(string)
	division, _ := session.Values["user_division"].(string)
	return id, role, name, division
}

func getLiveDivision(c *gin.Context, userID int) string {
	user, err := repository.GetUserByID(userID)
	if err != nil {
		_, _, _, div := GetSessionUser(c)
		return div
	}
	session, _ := Store.Get(c.Request, sessionName)
	session.Values["user_division"] = user.Division
	session.Save(c.Request, c.Writer)
	return user.Division
}
