package main

import (
	"database/sql"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	_ "github.com/lib/pq"
)

func conn_db() *sql.DB {
	connStr := "postgres://postgres:postgres@localhost/postgres?sslmode=disable"
	db, err := sql.Open("postgres", connStr)
	checkError(err)

	return db
}

func main() {
	db := conn_db()

	e := echo.New()
	e.Use(middleware.Gzip())

	// TODO: create query so user can select table they want --> obviously from a list of presets :)
	e.GET("/", func(c echo.Context) error {
		htmlRes := ""
		err := db.QueryRow("select get_from_cache_or_compute('select id, name, capital, currency_name, region, subregion, latitude, longitude, created_at, updated_at from countries', 'Countries')").
			Scan(&htmlRes)
		checkError(err)
		return c.HTML(http.StatusOK, htmlRes)
	})
	e.Logger.Fatal(e.Start(":1323"))
}

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}

