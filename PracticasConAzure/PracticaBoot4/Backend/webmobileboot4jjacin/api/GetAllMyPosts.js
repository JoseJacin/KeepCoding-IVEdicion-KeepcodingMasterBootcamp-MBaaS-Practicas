// API que recupera todos los Posts
module.exports = {
    "get": function (req, res, next) {
        if (typeof req.params.lenght < 0) {
            console.log("error en llista de parámetros");
        }

        // Se monta la consulta SQL
        var query = { sql: "SELECT * FROM Posts" };
        
        // Se ejecuta la consulta
        req.azureMobile.data.execute(query)
        // Si hay algún resultado
        .then(function (result) {
            res.json(result);
        });
    }
}
