// API que recupera los Posts que se encuentran con el status a Publish
module.exports = {
    "get": function (req, res, next) {
        // Se monta la consulta SQL
        var query = { sql: "SELECT * FROM Posts Where status = 1" };
        
        // Se ejecuta la consulta
        req.azureMobile.data.execute(query)
        // Si hay algún resultado
        .then(function (result) {
            res.json(result);
        });
    }
}
