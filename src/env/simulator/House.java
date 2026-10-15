package simulator;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JPanel;

import cartago.OPERATION;
import cartago.tools.GUIArtifact;

public class House extends GUIArtifact {

    HouseView view;

    @Override
    public void init(){
        view = new HouseView();
        view.setVisible(true);
    }

    // Actions that simulate the building progress

    @OPERATION void prepareSite(){
        view.addPart(new Site());
        signal("sitePrepared");
    }

    @OPERATION void layFloors(){
        await_time(1000);
        view.addPart(new Floor());
        signal("floorsLayed");
    }

    @OPERATION void buildWalls(){
        await_time(500);
        view.addPart(new Walls());
        signal("wallsBuilt");
    }

    @OPERATION void buildRoof(){
        await_time(1000);
        view.addPart(new Roof());
        signal("roofBuilt");
    }

    @OPERATION void fitDoors(){
        await_time(300);
        view.addPart(new Doors());
        signal("doorsFitted");
    }

    @OPERATION void fitWindows(){
        await_time(300);
        view.addPart(new Windows());
        signal("windowsFitted");
    }

    @OPERATION void paintExterior(){
        await_time(2000);
        view.addPart(new ExteriorPainting());
        signal("exteriorPainted");
    }

    @OPERATION void installPlumbing(){
        await_time(300);
        view.addPart(new Plumbing());
        signal("plumbingInstalled");
    }

    @OPERATION void installElectricalSystem(){
        await_time(300);
        view.addPart(new ElectricalSystem());
        signal("electricalSystemInstalled");
    }

    @OPERATION void paintInterior(){
        await_time(500);
        view.addPart(new InteriorPainting());
        signal("interiorPainted");
    }


    class HouseView extends JFrame {

        HousePanel           housePanel;
        ArrayList<HousePart> partsToDraw;

        public HouseView(){
            setTitle(" -- Home Sweet Home -- ");
            setSize(800,600);

            partsToDraw = new ArrayList<HousePart>();
            housePanel  = new HousePanel(this);
            setContentPane(housePanel);
        }

        public synchronized void addPart(HousePart part){
            partsToDraw.add(part);
            repaint();
        }

        public synchronized ArrayList<HousePart> getParts(){
            return (ArrayList<HousePart>)partsToDraw.clone();
        }
    }

    class HousePanel extends JPanel {

        HouseView view;

        public HousePanel(HouseView view){
            this.view = view;
        }

        public void paintComponent(Graphics g) {
            super.paintComponent(g);

               g.setColor(Color.WHITE);
               Dimension size = getSize();
               g.fillRect(0, 0, size.width, size.height);

               for (HousePart part: view.getParts()){
                   part.draw(size,(Graphics2D)g);
               }
        }
    }
}
