// +build enterprise

package migrations

import "github.com/requaos/qorfun/app/enterprise"

func init() {
	AutoMigrate(&enterprise.QorMicroSite{})
}
