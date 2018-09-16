package config

import (
	"fmt"
	"time"

	"github.com/spf13/viper"
)

var defaultConfig *viper.Viper

const (
	dbUsername = "db_username"
	dbPassword = "db_password"
	dbHost     = "db_host"
	dbName     = "db_name"
	dbPort     = "db_port"
)

func init() {
	defaultConfig = getSettings()
}

func DBHost() string {
	return defaultConfig.GetString(dbHost)
}

func DBPort() string {
	return defaultConfig.GetString(dbPort)
}

func DBName() string {
	return defaultConfig.GetString(dbName)
}

func DBUsername() string {
	return defaultConfig.GetString(dbUsername)
}

func DBPassword() string {
	return defaultConfig.GetString(dbPassword)
}

func getSettings() *viper.Viper {
	v := viper.New()

	v.SetConfigType("toml")
	v.SetConfigName("settings")
	v.AddConfigPath("./")
	err := v.ReadInConfig()
	if err != nil {
		fmt.Println(time.Now().String())
		fmt.Println(err.Error())
	}

	v.SetDefault(dbHost, "localhost")
	v.SetDefault(dbPort, "5432")
	v.SetDefault(dbName, "qorfun")
	v.SetDefault(dbUsername, "qorfun")
	v.SetDefault(dbPassword, "")

	v.AutomaticEnv()

	return v
}
