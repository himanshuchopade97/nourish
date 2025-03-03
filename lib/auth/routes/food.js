const express = require("express");
const Food = require("../models/Food");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Store food data
router.post("/api/add-food", authMiddleware, async (req, res) => {
    const { food_name, protein_g, carb_g, fat_g, fibre_g, energy_kcal, glycemic_index  } = req.body;
    console.log("🛠️ Request received:", req.body);
    console.log("🔑 User ID:", req.user?.userId);
    if (!food_name) {
        return res.status(400).json({ message: "No food selected!" });
    }

    try {
        const food = await Food.create({
            userId:req.user.userId,
            food_name,
            protein_g,
            carb_g,
            fat_g,
            fibre_g,
            energy_kcal,
            glycemic_index: glycemic_index ?? null,
            createdAt: new Date(),
        });

        console.log("✅ Food added to DB:", food);
        res.json({ message: "Food added successfully", food });
    } catch (err) {
        console.error("❌ Error adding food:", err);
        res.status(500).json({ message: "Error adding food" });
    }
});

router.get("/api/selected-food", authMiddleware, async (req, res) => {
    try {
      const foods = await Food.find({ userId: req.user.userId });
      res.json(foods);
    } catch (err) {
      console.log(err);
      res.status(500).json({ message: "Error fetching foods" });
    }
  });
module.exports = router;
