//
//  ViewController.swift
//  Poketrader
//
//  Created by Nathan Reeves on 8/23/16.
//  Copyright © 2016 Nathan Reeves. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate{
    
    
    

    @IBOutlet var Map: MKMapView!
    var locations = [CLLocationCoordinate2D]()
    let me : CLLocationManager = CLLocationManager()
    var myPin : MKPointAnnotation?
    var oldPin : MKPointAnnotation?
    //@IBOutlet var Label: UILabel!
    //@IBOutlet var Post: UIButton!
    //@IBOutlet var Search: UIButton!
    @IBOutlet var Post: UIButton!
    var SearchPoke = "Start"
    var PostCP = "0"
    var posting  = false
    var pokemonOwn = "0"
    var pokemonWant = "0"
    var myTrade : Trade?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Need to Draw Any trades on the map
        me.delegate = self
        Map.delegate = self
        me.requestWhenInUseAuthorization()
        //FIRAuth.auth()?.signIn(withEmail: "nathan.m.reeves@gmail.com", password: "Syymnatedog1", completion: nil)
        FIRAuth.auth()?.signInAnonymously() { (user, error) in
            // ...
            //let isAnonymous = user!.isAnonymous  // true
            //let uid = user!.uid
        }
        //print(FIRAuth.auth()?.currentUser ?? "None")
        //queryTrades()
        
        let buttonImage = UIImage(named: "offer.png")
        
        
        Post.setImage(buttonImage, for: UIControlState())
        
        var location = CLLocationCoordinate2DMake(40.699183, -111.878566)
        locations.append(location)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        
        Post.addTarget(self, action: #selector(startPost), for: .touchUpInside)
        if(locations.count>=2)
        {
            print(locations[1])
            location = locations[1]
        }
        let region = MKCoordinateRegion(center: location, span: span)
        let ref = FIRDatabase.database().reference(fromURL: "https://poketrader-7143c.firebaseio.com/")
        
        ref.child("Posts")
            .queryOrdered(byChild: "latitude")
            .observe(.childAdded, with: { snapshot in
                let poke = snapshot.childSnapshot(forPath: "Pokemon Owned").value as! String
                let time = snapshot.childSnapshot(forPath: "Time").value as! TimeInterval
                let id = snapshot.childSnapshot(forPath: "User").value as! String
                let long = snapshot.childSnapshot(forPath: "longitude").value as! CLLocationDegrees
                let lat = snapshot.childSnapshot(forPath: "latitude").value as! CLLocationDegrees
                let newLocation = CLLocationCoordinate2DMake(lat, long)
                //if statement about time
                self.locations.append(newLocation)
                
                let newannotation = CustomPointAnnotation()
                
                newannotation.coordinate.latitude = newLocation.latitude
                newannotation.coordinate.longitude = newLocation.longitude
                if(id == FIRAuth.auth()!.currentUser!.uid)
                {
                    self.myPin = newannotation
                    print("found my pin")
                    
                }
                newannotation.imageName = poke
                newannotation.timeData = time
                self.Map.addAnnotation(newannotation)
                print("printing", newLocation)
                print(self.locations.count)
                
                
                
                
                //print(snapshot.childSnapshotForPath("latitude").value)
                
            })
        if (posting){
            postLocation()
        }
        Map.setRegion(region, animated: true)
        Map.showsUserLocation = true
        
    }
    func startPost()
    {
        
        let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc : UIViewController = storyboard.instantiateViewController(withIdentifier: "PostCriteria") as UIViewController
        self.present(vc, animated: true, completion: nil)
        
        
        
    }
    func postLocation()
    {
        //need to get and delete users old pin
        
        Post.isEnabled = false
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(handleTap))
        Map.addGestureRecognizer(gestureRecognizer)
        
    }
    func queryTrades()
    {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://poketrader-7143c.firebaseio.com/")
        
        ref.child("Posts")
            .queryOrdered(byChild: "latitude")
            .observe(.childAdded, with: { snapshot in
                let poke = snapshot.childSnapshot(forPath: "Pokemon Owned").value as! String
                let time = snapshot.childSnapshot(forPath: "Time").value as! TimeInterval
                let id = snapshot.childSnapshot(forPath: "User").value as! String
                let long = snapshot.childSnapshot(forPath: "longitude").value as! CLLocationDegrees
                let lat = snapshot.childSnapshot(forPath: "latitude").value as! CLLocationDegrees
                let newLocation = CLLocationCoordinate2DMake(lat, long)
                //if statement about time
                self.locations.append(newLocation)
                
                let newannotation = CustomPointAnnotation()
                
                newannotation.coordinate.latitude = newLocation.latitude
                newannotation.coordinate.longitude = newLocation.longitude
                if(id == FIRAuth.auth()!.currentUser!.uid)
                {
                    self.myPin = newannotation
                    print("found my pin")
                    
                }
                newannotation.imageName = poke
                newannotation.timeData = time
                self.Map.addAnnotation(newannotation)
                print("printing", newLocation)
                print(self.locations.count)
                
                
                
                
                //print(snapshot.childSnapshotForPath("latitude").value)
                
            })
        
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        _ = view.annotation as! CustomPointAnnotation
        let ac = UIAlertController();
        ac.addAction(UIAlertAction(title: "YO", style: .default, handler: nil))
        print("yo");
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let calloutView = UIAlertController().view
        calloutView?.translatesAutoresizingMaskIntoConstraints = false
        calloutView?.backgroundColor = UIColor.lightGray
        view.addSubview(calloutView!)
        
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        //queryTrades()
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //queryTrades()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView!.canShowCallout = true
        let pokemon = annotation as! CustomPointAnnotation
        
        annotationView!.image = UIImage(named: pokemon.imageName)
        
        return annotationView
        
    }
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
        var timeData: TimeInterval!
    }
    func handleTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.location(in: Map)
        let coordinate = Map.convert(location,toCoordinateFrom: Map)
        Post.isEnabled = true
        
        Map.removeGestureRecognizer(gestureReconizer)
        // Add annotation:
        let annotation = CustomPointAnnotation()
        annotation.coordinate = coordinate
        let date = Date()
        myTrade = Trade(latitude: coordinate.latitude, longitude: coordinate.longitude, name: "yo", poke: pokemonOwn, poke2: pokemonWant, date : date.timeIntervalSince1970)
        annotation.imageName = pokemonOwn //users final pokemon Pin
        myTrade!.uploadTradeData()
        
        Map.addAnnotation(annotation)
        if(self.myPin != nil)
        {
            self.myPin?.subtitle = ""
            self.oldPin = self.myPin
            Map.removeAnnotation(self.myPin!)
            self.myPin = annotation
            
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

class PostCriteria: UIViewController, postCriteriaData{
    
    //@IBOutlet var Logout: UIBarButtonItem!
    @IBOutlet var pokemonOwn: UIButton!
    @IBOutlet var pokemonWant: UIButton!
    //@IBOutlet var CP: UITextField!
    @IBOutlet var PKW3: UIButton!
    @IBOutlet var PKW2: UIButton!
    @IBOutlet var Back: UIButton!
    @IBOutlet var CP: UILabel!
    @IBOutlet var Timeslide: UISlider!
    @IBOutlet var CPslide: UISlider!
    @IBOutlet var Post: UIButton!
    var pk: Int = -1
    var pokemonSelected: String = "1"
    var pokemonSelected2: String = "2"
    override func viewDidLoad() {
        super.viewDidLoad()
        CPslide.maximumValue = 3500
        CPslide.minimumValue = 1
        //CPslide.
        pokemonOwn.setImage(#imageLiteral(resourceName: "add"), for: UIControlState())
        pokemonWant.setImage(#imageLiteral(resourceName: "add"), for: UIControlState())
        Back.addTarget(self, action: #selector(back), for: .touchUpInside)
        pokemonOwn.addTarget(self, action: #selector(selector), for: .touchUpInside)
        pokemonWant.addTarget(self, action: #selector(selector2), for: .touchUpInside)
        PKW2.addTarget(self, action: #selector(selector3), for: .touchUpInside)
        PKW3.addTarget(self, action: #selector(selector4), for: .touchUpInside)

        //Logout.action = #selector(logout)
        
        // Do any additional setup after loading the view.
    }

    func acceptData(_ data: String, top: Bool) {
        if top{
            pokemonOwn.setImage(UIImage(named: data), for: UIControlState())
            pokemonSelected = data
            print("Poke " + data)
        }
        else{
            if(pk == 0)
            {
                pokemonWant.setImage(UIImage(named: data), for: UIControlState())
                pokemonSelected2 = data
                print("Poke " + data)
            }
            else if(pk == 1)
            {
                PKW2.setImage(UIImage(named: data), for: UIControlState())
                //PKW2 = data
                print("Poke " + data)
            
            }
            else{
                PKW3.setImage(UIImage(named: data), for: UIControlState())
                //PKW2 = data
                print("Poke " + data)

                
            }
            
        }
        
    }
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        print(Int(sender.value))
        CP.text = "\(currentValue)"
    }
    func logout()
    {
        do
        {
            try
                FIRAuth.auth()?.signOut()
        }
        catch let logoutError{
            
            print(logoutError)
        }
        let login = LoginScreen()
        present(login, animated: true, completion: nil)
    }
    
    func selector()
    {
        let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc : PokemonView = storyboard.instantiateViewController(withIdentifier: "PokemonView") as! PokemonView
        vc.delegate = self
        vc.top = true
        self.present(vc, animated: true, completion: nil)
        
    }
    func selector2()
    {
        let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc : PokemonView = storyboard.instantiateViewController(withIdentifier: "PokemonView") as! PokemonView
        vc.delegate = self
        vc.top = false
        pk = 0
        if(PKW2.image(for: UIControlState()) == nil)
        {
           PKW2.setImage(#imageLiteral(resourceName: "add"), for: UIControlState())
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    func selector3()
    {
        let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc : PokemonView = storyboard.instantiateViewController(withIdentifier: "PokemonView") as! PokemonView
        vc.delegate = self
        vc.top = false
        pk = 1
        if(PKW3.image(for: UIControlState()) == nil)
        {
            PKW3.setImage(#imageLiteral(resourceName: "add"), for: UIControlState())
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    func selector4()
    {
        let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let vc : PokemonView = storyboard.instantiateViewController(withIdentifier: "PokemonView") as! PokemonView
        vc.delegate = self
        vc.top = false
        pk = 2
        self.present(vc, animated: true, completion: nil)
        
    }
    func back()
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ViewController
        
        dest.pokemonOwn = pokemonSelected
        dest.pokemonWant = pokemonSelected2
        dest.posting = true
        
        
        
        
        // Pass the selected object to the new view controller.
    }
    
    
    
}
class Trade : NSObject{
    
    var lat : Double = 0.0
    var long : Double = 0.0
    var pokemonO = "0"
    var pokemonW = "0"
    var user = ""
    var time : TimeInterval?
    init(latitude : Double, longitude : Double, name : String, poke: String, poke2: String, date : TimeInterval)
    {
        let location  = CLLocationCoordinate2DMake(latitude, longitude)
        time = date
        lat = location.latitude
        long = location.longitude
        pokemonO = poke
        pokemonW = poke2
        //user = FIRAuth.auth()!.currentUser!.uid
        
        
    }
    func uploadTradeData()
    {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://poketrader-7143c.firebaseio.com/")
        let usersTab = ref.child("Posts").child(FIRAuth.auth()!.currentUser!.uid)
        let uid = FIRAuth.auth()!.currentUser!.uid
        usersTab.updateChildValues(["Pokemon Owned" : pokemonO, "Pokemon Wanted" : pokemonW, "latitude" : lat, "longitude" : long, "User" : uid , "Time" : time!])
        
    }
    
    
}

