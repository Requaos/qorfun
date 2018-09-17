package migrations

import (
	"github.com/qor/activity"
	"github.com/qor/auth/auth_identity"
	"github.com/qor/banner_editor"
	"github.com/qor/help"
	"github.com/qor/media/asset_manager"
	"github.com/qor/transition"
	"github.com/requaos/qorfun/app/admin"
	"github.com/requaos/qorfun/config/db"
	"github.com/requaos/qorfun/models/blogs"
	"github.com/requaos/qorfun/models/orders"
	"github.com/requaos/qorfun/models/products"
	"github.com/requaos/qorfun/models/seo"
	"github.com/requaos/qorfun/models/settings"
	"github.com/requaos/qorfun/models/stores"
	"github.com/requaos/qorfun/models/users"
)

func init() {
	AutoMigrate(&asset_manager.AssetManager{})

	AutoMigrate(&products.Product{}, &products.ProductVariation{}, &products.ProductImage{}, &products.ColorVariation{}, &products.ColorVariationImage{}, &products.SizeVariation{})
	AutoMigrate(&products.Color{}, &products.Size{}, &products.Material{}, &products.Category{}, &products.Collection{})

	AutoMigrate(&users.User{}, &users.Address{})

	AutoMigrate(&orders.Order{}, &orders.OrderItem{})

	AutoMigrate(&orders.DeliveryMethod{})

	AutoMigrate(&stores.Store{})

	AutoMigrate(&settings.Setting{}, &settings.MediaLibrary{})

	AutoMigrate(&transition.StateChangeLog{})

	AutoMigrate(&activity.QorActivity{})

	AutoMigrate(&admin.QorWidgetSetting{})

	AutoMigrate(&blogs.Page{}, &blogs.Article{})

	AutoMigrate(&seo.MySEOSetting{})

	AutoMigrate(&help.QorHelpEntry{})

	AutoMigrate(&auth_identity.AuthIdentity{})

	AutoMigrate(&banner_editor.QorBannerEditorSetting{})
}

// AutoMigrate run auto migration
func AutoMigrate(values ...interface{}) {
	for _, value := range values {
		db.DB.AutoMigrate(value)
	}
}
