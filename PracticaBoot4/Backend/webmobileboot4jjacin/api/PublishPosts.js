// API que publica un Post determinado
module.exports = {
    "put": function (req, res, next) {
        // Se almacena en una variable el parámetro estado recibido en req
        var estado = req.query.estado
        // Se almacena en una variable el parámetro item recibido en req
        var item = req.query.id
        
        // Se monta la consulta SQL
        var query = { sql: "UPDATE SET status = @status WHERE id = @id", 
            parameters: [{id: item, status: estado}]  
            };
            
       // Se ejecuta la consulta
       req.azureMobile.data.execute(query)
       // Si hay algún resultado
       .then(function(result) {
           res.json(result)
       });
    }
}
