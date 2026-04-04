from flask import Blueprint, jsonify, request
import random, math


demand_bp = Blueprint("demand", __name__, url_prefix="/api/demand")

# Stub demand data — in production replace with real LSTM output
ZONE_DEMAND = {
    "North": {"base_index": 0.72, "peak_hours": [12, 13, 19, 20, 21]},
    "South": {"base_index": 0.58, "peak_hours": [11, 12, 19, 20]},
    "East": {"base_index": 0.65, "peak_hours": [12, 13, 20, 21]},
    "West": {"base_index": 0.48, "peak_hours": [11, 12, 18, 19]},
    "Central": {"base_index": 0.81, "peak_hours": [11, 12, 13, 19, 20, 21]},
}


@demand_bp.route("/zone/<zone_name>", methods=["GET"])
def zone_demand(zone_name):
    zone_data = ZONE_DEMAND.get(zone_name, ZONE_DEMAND["Central"])
    from datetime import datetime

    hour = datetime.utcnow().hour + 5  # IST
    is_peak = hour % 24 in zone_data["peak_hours"]
    demand = zone_data["base_index"] * (1.3 if is_peak else 0.85)
    return jsonify(
        {
            "zone": zone_name,
            "demand_index": round(min(demand, 1.0), 2),
            "forecast_label": "High demand" if demand > 0.7 else "Moderate",
            "recommended": demand > 0.65,
            "model": "LSTM-stub-v1",
            "peak_hours": zone_data["peak_hours"],
        }
    )
