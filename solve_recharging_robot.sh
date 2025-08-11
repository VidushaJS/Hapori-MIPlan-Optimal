#!/bin/bash

# Define paths
DOMAIN_FILE="domains/recharging_robot_domain.pddl"
PROBLEM_DIR="problems/recharging_robot"
SOLUTION_DIR="solutions/recharging_robot"
LOG_DIR="logs/recharging_robot"
PLANNER_IMAGE="./hapori_miplan_opt.img"  # Adjust if using ipc2018-opt-complementary2.img

# Check if planner image exists and is executable
if [ ! -f "$PLANNER_IMAGE" ] || [ ! -x "$PLANNER_IMAGE" ]; then
    echo "Error: Planner image $PLANNER_IMAGE not found or not executable"
    exit 1
fi

# Check if domain file exists
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "Error: Domain file $DOMAIN_FILE not found"
    exit 1
fi

# Check if problem directory exists
if [ ! -d "$PROBLEM_DIR" ]; then
    echo "Error: Problem directory $PROBLEM_DIR not found"
    exit 1
fi

# Create solutions directory if it doesn't exist
mkdir -p "$SOLUTION_DIR"
mkdir -p "$LOG_DIR"

# Check if Apptainer is installed
if ! command -v apptainer &> /dev/null; then
    echo "Error: Apptainer not installed. Install with: sudo apt install apptainer"
    exit 1
fi

# Iterate over all .pddl files in the problem directory
for PROBLEM_FILE in "$PROBLEM_DIR"/*.pddl; do
    # Skip if no .pddl files are found
    if [ ! -f "$PROBLEM_FILE" ]; then
        echo "No .pddl files found in $PROBLEM_DIR"
        exit 1
    fi

    # Extract the base name (e.g., pb01 from pb01.pddl)
    BASE_NAME=$(basename "$PROBLEM_FILE" .pddl)
    # Construct output file name (e.g., bw_pb01_sol.txt)
    OUTPUT_FILE="$SOLUTION_DIR/${BASE_NAME}_sol.txt"
    LOG_FILE="$LOG_DIR/${BASE_NAME}.log"

    echo "Solving $PROBLEM_FILE..."

    # Run the planner
    "$PLANNER_IMAGE" "$DOMAIN_FILE" "$PROBLEM_FILE" "$OUTPUT_FILE" > "$LOG_FILE" 2>&1

    # Check if the plan was generated successfully
    if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ]; then
        echo "Solution saved to $OUTPUT_FILE"
	echo "Console output saved to $LOG_FILE"
    else
        echo "Failed to solve $PROBLEM_FILE or save to $OUTPUT_FILE"
	echo "Check $LOG_FILE for details"
    fi
done

echo "All problems processed."
