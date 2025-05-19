const Trip = require('../models/trip.model');

exports.createTrip = async (req, res) => {
    try {
        const { title, description, location, startDate, endDate } = req.body;
        const newTrip = new Trip({
            userId: req.userId, // Assuming you have auth middleware to get userId
            title,
            description,
            location,
            startDate,
            endDate,
        });
        await newTrip.save();
        res.status(201).json({ message: 'Trip created successfully', trip: newTrip });
    } catch (error) {
        res.status(500).json({ message: 'Error creating trip', error: error.message });
    }
};

exports.getAllTrips = async (req, res) => {
    try {
        const trips = await Trip.find().populate('userId', 'username'); // Populate user details
        res.status(200).json({ trips });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching trips', error: error.message });
    }
};

// Implement more controllers for updating, deleting, and fetching single trips