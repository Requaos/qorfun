package main

import (
	"fmt"
	"net/http"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"

	"github.com/qor/admin"
	"github.com/qor/qor"

	"github.com/requaos/qorfun/internal/config"
)

// Define a GORM-backend model
type User struct {
	gorm.Model
	Name string
}

// Define another GORM-backend model
type Product struct {
	gorm.Model
	Name        string
	Description string
}

func main() {
	// configure db access
	psqlInfo := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		config.DBHost(), config.DBPort(), config.DBUsername(), config.DBPassword(), config.DBName())

	// Set up the database
	DB, _ := gorm.Open("postgres", psqlInfo)
	DB.AutoMigrate(&User{}, &Product{})

	// Initalize
	Admin := admin.New(&qor.Config{DB: DB})

	// Site Name
	Admin.SetSiteName("QOR DEMO")

	// Create resources from GORM-backend model
	Admin.AddResource(&User{})
	Admin.AddResource(&Product{})

	// Register route
	mux := http.NewServeMux()
	// amount to /admin, so visit `/admin` to view the admin interface
	Admin.MountTo("/admin", mux)

	fmt.Println("Listening on: 9000")
	http.ListenAndServe(":9000", mux)
}
