from django.apps import AppConfig

import os
import cv2
from detectron2.config import get_cfg
from detectron2.engine import DefaultPredictor
from detectron2.data import MetadataCatalog

class PathAPIConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'PathAPI'

    MODEL_DIRECTORY = os.getcwd() + "/PathAPI/models"
    cfg = get_cfg()
    cfg.merge_from_file(os.path.join(MODEL_DIRECTORY, "experiment_config.yml"))
    cfg.MODEL.WEIGHTS = os.path.join(MODEL_DIRECTORY, "model_final.pth")
    cfg.MODEL.DEVICE = 'cpu'

    # Set metadata, in this case only the class names for plotting
    MetadataCatalog.get("meta").thing_classes = ["hold", "volume"]

    # Create a global variable to store the predictor
    predictor = DefaultPredictor(cfg)
