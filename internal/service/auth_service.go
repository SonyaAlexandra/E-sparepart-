package service

import (
	"errors"

	"golang.org/x/crypto/bcrypt"

	"sparepart-mgmt/internal/model"
	"sparepart-mgmt/internal/repository"
)

type LoginResult struct {
	User *model.User
}

func Login(username, password string) (*model.User, error) {
	user, err := repository.GetUserByUsername(username)
	if err != nil {
		return nil, errors.New("username atau password salah")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
	if err != nil {
		return nil, errors.New("username atau password salah")
	}

	return user, nil
}

func HashPassword(plain string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(bytes), err
}
