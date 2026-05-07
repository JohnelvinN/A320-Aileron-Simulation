clear;
clc;
close all;

load("data.mat");
Dp = 0.04;
dr = 0.016;
clearence = 0.01;
K = 2.2*10^9;

m =(0.25*clearence*pi*Dp^2 + 0.25*(max(x)+0.05)*pi*dr^2)*8050;
A = pi*(Dp^2 - dr^2)/4;
V0 = A*(min(P) - clearence)/2;

 