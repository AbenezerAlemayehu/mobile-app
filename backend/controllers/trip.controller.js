const Trip = require('../models/trip.model');
const path = require('path');
const fs = require('fs');

exports.createTrip = async (req, res) => {
    try {
        console.log('Received trip data:', req.body);
        console.log('Received file:', req.file);
        
        // Extract data from form fields
        const { title, description, location, startDate, endDate, budget, numberOfPeople } = req.body;
        
        // Validate required fields
        if (!title || !description || !location || !startDate) {
            return res.status(400).json({
                message: 'Missing required fields',
                error: 'Title, description, location, and startDate are required'
            });
        }

        // Handle image upload
        let imagePath;
        if (req.file) {
            // Ensure the uploads directory exists
            const uploadsDir = path.join(__dirname, '../uploads');
            if (!fs.existsSync(uploadsDir)) {
                fs.mkdirSync(uploadsDir, { recursive: true });
            }

            // Create the image path relative to the uploads directory
            imagePath = `/uploads/${req.file.filename}`;
            console.log('Image saved at:', imagePath);
        }

        // Create new trip
        const newTrip = new Trip({
            userId: req.userId,
            title,
            description,
            location,
            startDate: new Date(startDate),
            endDate: endDate ? new Date(endDate) : undefined,
            budget: budget ? parseFloat(budget) : undefined,
            numberOfPeople: numberOfPeople ? parseInt(numberOfPeople) : 1,
            imagePath: imagePath
        });

        await newTrip.save();
        console.log('Trip created successfully:', newTrip);

        res.status(201).json({ 
            message: 'Trip created successfully', 
            trip: newTrip 
        });
    } catch (error) {
        console.error('Error creating trip:', error);
        res.status(500).json({ 
            message: 'Error creating trip', 
            error: error.message 
        });
    }
};

exports.getAllTrips = async (req, res) => {
    try {
        const trips = await Trip.find().populate('userId', 'username');
        res.status(200).json({ trips });
    } catch (error) {
        res.status(500).json({ 
            message: 'Error fetching trips', 
            error: error.message 
        });
    }
};

// Implement more controllers for updating, deleting, and fetching single trips