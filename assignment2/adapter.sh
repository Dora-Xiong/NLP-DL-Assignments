#!/bin/bash

export TOKENIZERS_PARALLELISM=false
TASKS=("restaurant_sup" "acl_sup" "agnews_sup")
MODELS=("FacebookAI/roberta-base")
RUNS=5

# Loop through each model and task
for MODEL_NAME in "${MODELS[@]}"; do
  for TASK_NAME in "${TASKS[@]}"; do
    echo "Running experiments for model: ${MODEL_NAME} on dataset: ${TASK_NAME}"

    for ((RUN=1; RUN<=RUNS; RUN++)); do
      echo "Starting run ${RUN} for model: ${MODEL_NAME}, dataset: ${TASK_NAME}"

      # Execute the training command
      python train.py \
        --model_name_or_path ${MODEL_NAME} \
        --dataset_name ${TASK_NAME} \
        --do_train \
        --do_eval \
        --max_seq_length 128 \
        --per_device_train_batch_size 32 \
        --learning_rate 1e-4 \
        --num_train_epochs 10.0 \
        --output_dir $(pwd)/output/${TASK_NAME}_${MODEL_NAME}_adapter/run_${RUN}/ \
        --cache_dir $(pwd)/models/${MODEL_NAME}/ \
        --report_to wandb \
        --run_name "${TASK_NAME}_${MODEL_NAME//\//_}_adapter_run_${RUN}" \
        --logging_steps 50 \
        --eval_strategy steps \
        --overwrite_output_dir True \
        --train_adapter \
        --adapter_config double_seq_bn \

      echo "Completed run ${RUN} for model: ${MODEL_NAME}, dataset: ${TASK_NAME}"
    done
  done
done

echo "All experiments completed."