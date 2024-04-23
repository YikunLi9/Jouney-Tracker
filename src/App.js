import React from "react";
import { render } from "react-dom";
import { Parallax } from "react-parallax";
import ParticlesBg from "particles-bg";
import { AwesomeButton } from "react-awesome-button";
import Code from "./components/Code.jsx";
import Icons from "./components/Icons.jsx";

import "react-awesome-button/dist/styles.css";
import "./App.css";

import image1 from "./assets/01.jpeg";
import image2 from "./assets/02.jpeg";
import image3 from "./assets/03.jpeg";
import image4 from "./assets/04.jpeg";
import image5 from "./assets/05.jpeg";


const App = () => (
  <div className="main">
    <div className="container">
      <Parallax strength={500}>
        <ParticlesBg type="polygon" bg={true}/>
        <div style={{ height: 500 }}>
          <div className="boxs header">
            <h1 className="title">Journey Tracker</h1>
            <h4 className="introduction">
              Journey Tracker aims to enhance user experience by providing location tracking and data management functionalities, primarily helping users record and monitor their daily travel routes for better planning and analysis of their journeys.
            </h4>
            <div className="buttons">
              <a href="https://github.com/YikunLi9/Jouney-Tracker/tree/gh-pages">
                <AwesomeButton
                  size="medium"
                  type="secondary"
                >
                  homepage
                </AwesomeButton> 
              </a> 
              <div className="space"></div>
              <a href="https://github.com/YikunLi9/Jouney-Tracker/tree/main">
                <AwesomeButton
                  size="medium"
                  type="primary"
                >
                  github
                </AwesomeButton>
              </a> 
            </div>
          </div>
        </div>
      </Parallax>

      <Parallax bgImage={image1} blur={{ min: -1, max: 3 }}>
        <div style={{ height: 600 }}>
          <div className="boxs">
            <h1 className="underline">Project Introduction</h1>
            <div className="box-con">
              Sometimes on long journeys, it's easy to forget the places you've passed along the way, and during everyday city tours, you might not pay attention to the scenery around you. Therefore, Journey Tracker has been developed to record the routes we often forget and visualize them on a map, helping you recall every step of your travels.
            </div>
          </div>
        </div>
      </Parallax>

      <Parallax strength={-100}>
        <div style={{ height: 500 }}>
          <div className="boxs">
            <h1 className="blue underline">Characteristic</h1>
            <Icons />
            <div className="box-con blue">
              Journey Tracker enhances travel efficiency with its real-time location tracking and historical data visualization capabilities. It also boosts users' control over their personal information through robust data management and export features. Additionally, its excellent user experience design and main interface offer a smooth and intuitive user experience.
            </div>
          </div>
        </div>
      </Parallax>

      <Parallax
        bgImage={image4}
        strength={200}
        renderLayer={percentage => (
          <div>
            <div
              style={{
                position: "absolute",
                background: `rgba(255, 125, 0, ${percentage * 1})`,
                left: "50%",
                top: "50%",
                borderRadius: "50%",
                transform: "translate(-50%,-50%)",
                width: percentage * 500,
                height: percentage * 500
              }}
            />
          </div>
        )}
      >
        <div style={{ height: 500 }}>
          <div className="boxs">
            <div className="bsize">High efficiency, User friendly</div>
          </div>
        </div>
      </Parallax>

    </div>
    <div className="footer">Copyright Mr right. This code is open source.</div>
  </div>
);

export default App;
