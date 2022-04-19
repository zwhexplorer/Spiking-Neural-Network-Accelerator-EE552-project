# Spiking Neural Network Accelerator
Introduction

Motivated by industrial large-scale spiking neural networks TrueNorth and Loihi, we propose as a class project to model and implement a machine learning accelerator using an array of processing elements described using SystemVerilogCSP. Unlike TrueNorth and Loihi, however, we will target more traditional machine learning algorithms (e.g., convolutional neural networks (CNN)) and include a discussion of how CNNs have been mapped to asynchronous Spiking Neural Networks (SNNs). This will focus on the application of this technology in a domain that is quite relevant to today’s chip designers.
The class project will involve modeling the behavior of the neurons and associated network on chip (NoC) as well as implementing components in an asynchronous design style. The project will thus include aspects of architecture, micro-architecture, circuit design, modeling, and verification.
The class project will be broken into several phases. Students will self-organize into teams of 1, 2, or 3 students and grades will be given to each team (special permission from Prof. Beerel needed for teams of 4). It will include a required report (at least 10 pages) and class presentation that will be graded for both content and clarity. All students are expected to participate in the class presentation which is expected to be 8 minutes long. If needed due to time constraints some presentations will be held outside of normal class times.


For our design, we propose a Mesh topology with 5 routers. Each router has 5 ports, that is the four ports connected to other routers and the one port is a local port that is connected to the processing element. In this way, the next state of the system can be any one of the five ports east, west, north, and south or the local port. We use the XY Routing Algorithm to describe the address of each router. We use a 4-bit address to represent the XY coordinates[1]. The first 2 bits represent the X coordinate and the last 2 bits represent the Y coordinate. In XY routing, the comparison of the X coordinates values of the current router is done with the destination X coordinate. Based on the comparison the packet is transferred in the eastward or westward direction ports. Once X coordinates of the current router and destination address are the same, then the comparison base on the Y coordinates of the router is done. This comparison will route the packet to the north, south, or the local port of the router. 
