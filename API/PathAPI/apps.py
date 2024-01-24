import torch
from django.apps import AppConfig

import os
import cv2
from detectron2.config import get_cfg
from detectron2.engine import DefaultPredictor
from detectron2.data import MetadataCatalog

import torch
import torch.nn as nn
import torchvision


class TripletNet(nn.Module):
    def __init__(self):
        super(TripletNet, self).__init__()
        # get resnet model
        # weights = torchvision.models.ResNet18_Weights.DEFAULT
        weights = torchvision.models.ResNet50_Weights.DEFAULT
        self.preprocess = weights.transforms()
        self.resnet = torchvision.models.resnet50(weights=weights)

        self.fc_in_features = self.resnet.fc.in_features

        # remove fc layer from resnet
        self.resnet = nn.Sequential(*(list(self.resnet.children())[:-1]))

        self.fc = nn.Sequential(
            nn.Linear(self.fc_in_features, 256),
            nn.ReLU(inplace=True),
            nn.Linear(256, 256),
        )

        self.fc.apply(self.init_weights)

    def init_weights(self, m):
        if isinstance(m, nn.Linear):
            nn.init.xavier_uniform_(m.weight)
            m.bias.data.fill_(0.01)

    def forward_once(self, x):
        output = self.resnet(x)
        output = output.view(output.size()[0], -1)
        return output

    def forward(self, input):
        output = self.forward_once(input)
        output = self.fc(output)
        output = nn.functional.normalize(output, p=2)
        return output


class PathAPIConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'PathAPI'

    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    MODEL_DIRECTORY = os.getcwd() + "/PathAPI/models"
    cfg = get_cfg()
    cfg.merge_from_file(os.path.join(MODEL_DIRECTORY, "experiment_config.yml"))
    cfg.MODEL.WEIGHTS = os.path.join(MODEL_DIRECTORY, "model_final.pth")
    cfg.MODEL.DEVICE = 'cpu'

    # Set metadata, in this case only the class names for plotting
    MetadataCatalog.get("meta").thing_classes = ["hold", "volume"]

    # Create a global variable to store the predictor
    predictor = DefaultPredictor(cfg)
    triplet_model = TripletNet().to(device)

    triplet_model.load_state_dict(torch.load(MODEL_DIRECTORY + "/triplet_network_final.pt", map_location=device))
