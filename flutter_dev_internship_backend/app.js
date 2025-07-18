const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// DB Config
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  options: {
    encrypt: true, // For Azure SQL, set to false if local
    trustServerCertificate: true, // Change to false for production if cert is valid
  },
  // Optional pool config
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

async function connectToDb() {
  try {
    await sql.connect(dbConfig);
    console.log('Connected to SQL Server');
  } catch (err) {
    console.error('Database connection failed:', err);
  }
}

// Connect once when server starts
connectToDb();

// GET all products
app.get('/products', async (req, res) => {
  try {
    const result = await sql.query`SELECT * FROM PRODUCTS`;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET product by ID
app.get('/products/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  if (isNaN(id)) return res.status(400).json({ error: 'Invalid product ID' });

  try {
    const result = await sql.query`SELECT * FROM PRODUCTS WHERE PRODUCTID = ${id}`;
    if (result.recordset.length === 0) return res.status(404).json({ error: 'Product not found' });
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST new product
app.post('/products', async (req, res) => {
  const { PRODUCTNAME, PRICE, STOCK } = req.body;
  if (
    !PRODUCTNAME || typeof PRODUCTNAME !== 'string' || PRODUCTNAME.trim() === '' ||
    typeof PRICE !== 'number' || PRICE <= 0 ||
    typeof STOCK !== 'number' || STOCK < 0
  ) {
    return res.status(400).json({ error: 'Invalid input' });
  }

  try {
    await sql.query`
      INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) 
      VALUES (${PRODUCTNAME.trim()}, ${PRICE}, ${STOCK})
    `;
    res.status(201).json({ message: 'Product created' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update product by ID
app.put('/products', async (req, res) => {
  const id = parseInt(req.query.id);
  const { PRODUCTNAME, PRICE, STOCK } = req.body;

  if (isNaN(id)) return res.status(400).json({ error: 'Missing or invalid product ID' });

  if (
    !PRODUCTNAME || typeof PRODUCTNAME !== 'string' || PRODUCTNAME.trim() === '' ||
    typeof PRICE !== 'number' || PRICE <= 0 ||
    typeof STOCK !== 'number' || STOCK < 0
  ) {
    return res.status(400).json({ error: 'Invalid input' });
  }

  try {
    const result = await sql.query`
      UPDATE PRODUCTS 
      SET PRODUCTNAME = ${PRODUCTNAME.trim()}, PRICE = ${PRICE}, STOCK = ${STOCK} 
      WHERE PRODUCTID = ${id}
    `;

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE product by ID
app.delete('/products', async (req, res) => {
  const id = parseInt(req.query.id);
  if (isNaN(id)) return res.status(400).json({ error: 'Missing or invalid product ID' });

  try {
    const result = await sql.query`
      DELETE FROM PRODUCTS WHERE PRODUCTID = ${id}
    `;

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }

    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
