const express = require('express');
const tripController = require('../controllers/trip.controller');
const authMiddleware = require('../middleware/auth.middleware');
const router = express.Router();

router.post('/', authMiddleware, tripController.createTrip);
router.get('/', tripController.getAllTrips);
// Add more routes for specific trip operations (e.g., /:id for fetching one)

module.exports = router;