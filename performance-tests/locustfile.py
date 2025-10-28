"""
Locust Performance Tests for E-commerce Microservices
5 Real-world Use Cases per Microservice (50 total scenarios)
"""

from locust import HttpUser, task, between
import json
import random
import time

class EcommerceUser(HttpUser):
    """Main user class for e-commerce performance testing"""
    wait_time = between(1, 3)
    
    def on_start(self):
        """Initialize user session data"""
        self.user_id = random.randint(1, 10)
        self.product_id = random.randint(1, 10)
        self.order_id = None
        self.payment_id = None
        self.shipping_id = None

    # ==================== PRODUCT SERVICE TESTS ====================
    
    @task(15)
    def product_browse_catalog(self):
        """Use Case 1: Browse product catalog - most common action"""
        with self.client.get("/app/api/products", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data and len(data["collection"]) > 0:
                        response.success()
                    else:
                        response.failure("Empty or invalid product catalog")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(12)
    def product_search_by_id(self):
        """Use Case 2: Search for specific product by ID"""
        product_id = random.randint(1, 10)
        with self.client.get(f"/app/api/products/{product_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "productId" in data or "productTitle" in data:
                        response.success()
                    else:
                        response.failure("Invalid product data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def product_create_new(self):
        """Use Case 3: Create new product (admin action)"""
        product_data = {
            "productTitle": f"Performance Test Product {random.randint(1000, 9999)}",
            "sku": f"PERF{random.randint(1000, 9999)}",
            "priceUnit": round(random.uniform(10.0, 1000.0), 2),
            "quantity": random.randint(1, 100),
            "categoryDto": {
                "categoryId": random.randint(1, 3),
                "categoryTitle": random.choice(["Electronics", "Clothing", "Books"])
            }
        }
        
        with self.client.post("/app/api/products", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "productId" in data or "productTitle" in data:
                        response.success()
                    else:
                        response.failure("Invalid product creation response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def product_update_existing(self):
        """Use Case 4: Update existing product (admin action)"""
        product_id = random.randint(1, 10)
        product_data = {
            "productTitle": f"Updated Product {random.randint(1000, 9999)}",
            "sku": f"UPD{random.randint(1000, 9999)}",
            "priceUnit": round(random.uniform(20.0, 500.0), 2),
            "quantity": random.randint(5, 50)
        }
        
        with self.client.put(f"/app/api/products/{product_id}", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def product_delete_existing(self):
        """Use Case 5: Delete product (admin action)"""
        product_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/products/{product_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== USER SERVICE TESTS ====================
    
    @task(12)
    def user_browse_users(self):
        """Use Case 1: Browse user list (admin action)"""
        with self.client.get("/app/api/users", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(10)
    def user_get_by_username(self):
        """Use Case 2: Get user by username (login scenario)"""
        usernames = ["testuser", "admin", "selimhorri", "amineladjimi", "omarderouiche"]
        username = random.choice(usernames)
        with self.client.get(f"/app/api/users/username/{username}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "firstName" in data:
                        response.success()
                    else:
                        response.failure("Invalid user data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def user_register_new(self):
        """Use Case 3: Register new user (signup scenario)"""
        user_data = {
            "firstName": f"PerfUser{random.randint(1000, 9999)}",
            "lastName": f"LastName{random.randint(1000, 9999)}",
            "email": f"perf{random.randint(1000, 9999)}@example.com",
            "phone": f"+123456{random.randint(1000, 9999)}",
            "credential": {
                "username": f"perfuser{random.randint(1000, 9999)}",
                "password": "hashed_password",
                "roleBasedAuthority": "ROLE_USER",
                "isEnabled": True
            }
        }
        
        with self.client.post("/app/api/users", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "firstName" in data:
                        response.success()
                    else:
                        response.failure("Invalid user registration response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def user_update_profile(self):
        """Use Case 4: Update user profile (profile management)"""
        user_id = random.randint(1, 10)
        user_data = {
            "firstName": f"UpdatedUser{random.randint(1000, 9999)}",
            "lastName": f"UpdatedLastName{random.randint(1000, 9999)}",
            "email": f"updated{random.randint(1000, 9999)}@example.com",
            "phone": f"+123456{random.randint(1000, 9999)}"
        }
        
        with self.client.put(f"/app/api/users/{user_id}", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def user_delete_account(self):
        """Use Case 5: Delete user account (account deletion)"""
        user_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/users/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== ORDER SERVICE TESTS ====================
    
    @task(10)
    def order_browse_orders(self):
        """Use Case 1: Browse orders (order history)"""
        with self.client.get("/app/api/orders", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid order list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def order_create_new(self):
        """Use Case 2: Create new order (checkout process)"""
        order_data = {
            "orderDesc": f"Performance Test Order {random.randint(1000, 9999)}",
            "orderFee": round(random.uniform(50.0, 500.0), 2),
            "cart": {
                "cartId": random.randint(1, 100),
                "userId": self.user_id
            }
        }
        
        with self.client.post("/app/api/orders", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "orderId" in data or "orderDesc" in data:
                        self.order_id = data.get("orderId", random.randint(1, 10))
                        response.success()
                    else:
                        response.failure("Invalid order creation response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def order_get_by_id(self):
        """Use Case 3: Get order by ID (order details)"""
        order_id = random.randint(1, 10)
        with self.client.get(f"/app/api/orders/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "orderId" in data or "orderDesc" in data:
                        response.success()
                    else:
                        response.failure("Invalid order data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def order_update_status(self):
        """Use Case 4: Update order status (order management)"""
        order_id = random.randint(1, 10)
        order_data = {
            "orderDesc": f"Updated Order {random.randint(1000, 9999)}",
            "orderFee": round(random.uniform(100.0, 600.0), 2)
        }
        
        with self.client.put(f"/app/api/orders/{order_id}", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def order_cancel_order(self):
        """Use Case 5: Cancel order (order cancellation)"""
        order_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/orders/{order_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== PAYMENT SERVICE TESTS ====================
    
    @task(10)
    def payment_browse_payments(self):
        """Use Case 1: Browse payment history"""
        with self.client.get("/app/api/payments", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid payment list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def payment_process_payment(self):
        """Use Case 2: Process payment (payment processing)"""
        payment_data = {
            "isPayed": random.choice([True, False]),
            "paymentStatus": random.choice(["IN_PROGRESS", "COMPLETED", "FAILED"]),
            "order": {
                "orderId": random.randint(1, 10),
                "orderDesc": f"Payment Test Order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(50.0, 500.0), 2)
            }
        }
        
        with self.client.post("/app/api/payments", 
                            json=payment_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "paymentId" in data or "isPayed" in data:
                        self.payment_id = data.get("paymentId", random.randint(1, 10))
                        response.success()
                    else:
                        response.failure("Invalid payment processing response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def payment_get_by_id(self):
        """Use Case 3: Get payment by ID (payment details)"""
        payment_id = random.randint(1, 10)
        with self.client.get(f"/app/api/payments/{payment_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "paymentId" in data or "isPayed" in data:
                        response.success()
                    else:
                        response.failure("Invalid payment data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def payment_update_status(self):
        """Use Case 4: Update payment status (payment management)"""
        payment_id = random.randint(1, 10)
        payment_data = {
            "isPayed": True,
            "paymentStatus": "COMPLETED"
        }
        
        with self.client.put(f"/app/api/payments/{payment_id}", 
                            json=payment_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def payment_refund_payment(self):
        """Use Case 5: Refund payment (refund processing)"""
        payment_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/payments/{payment_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== SHIPPING SERVICE TESTS ====================
    
    @task(10)
    def shipping_browse_shippings(self):
        """Use Case 1: Browse shipping records"""
        with self.client.get("/app/api/shippings", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid shipping list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(8)
    def shipping_create_shipment(self):
        """Use Case 2: Create new shipment (shipping process)"""
        shipping_data = {
            "shippingAddress": f"{random.randint(100, 999)} Performance Test Street, Test City",
            "shippingStatus": random.choice(["PENDING", "SHIPPED", "DELIVERED"]),
            "order": {
                "orderId": random.randint(1, 10),
                "orderDesc": f"Shipping Test Order {random.randint(1000, 9999)}",
                "orderFee": round(random.uniform(50.0, 500.0), 2)
            }
        }
        
        with self.client.post("/app/api/shippings", 
                            json=shipping_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "shippingId" in data or "shippingAddress" in data:
                        self.shipping_id = data.get("shippingId", random.randint(1, 10))
                        response.success()
                    else:
                        response.failure("Invalid shipping creation response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def shipping_track_shipment(self):
        """Use Case 3: Track shipment (tracking functionality)"""
        shipping_id = random.randint(1, 10)
        with self.client.get(f"/app/api/shippings/{shipping_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "shippingId" in data or "shippingStatus" in data:
                        response.success()
                    else:
                        response.failure("Invalid shipping data structure")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def shipping_update_status(self):
        """Use Case 4: Update shipping status (status management)"""
        shipping_id = random.randint(1, 10)
        shipping_data = {
            "shippingStatus": random.choice(["SHIPPED", "IN_TRANSIT", "DELIVERED"]),
            "shippingAddress": f"{random.randint(100, 999)} Updated Street, Test City"
        }
        
        with self.client.put(f"/app/api/shippings/{shipping_id}", 
                            json=shipping_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def shipping_cancel_shipment(self):
        """Use Case 5: Cancel shipment (cancellation)"""
        shipping_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/shippings/{shipping_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    # ==================== FAVOURITE SERVICE TESTS ====================
    
    @task(8)
    def favourite_browse_favourites(self):
        """Use Case 1: Browse user favourites"""
        with self.client.get("/app/api/favourites", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid favourite list format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(6)
    def favourite_add_to_favourites(self):
        """Use Case 2: Add product to favourites (wishlist)"""
        favourite_data = {
            "userId": self.user_id,
            "productId": self.product_id,
            "user": {
                "userId": self.user_id,
                "firstName": f"User{random.randint(1000, 9999)}",
                "lastName": f"LastName{random.randint(1000, 9999)}",
                "email": f"user{random.randint(1000, 9999)}@example.com"
            },
            "product": {
                "productId": self.product_id,
                "productTitle": f"Favourite Product {random.randint(1000, 9999)}",
                "sku": f"FAV{random.randint(1000, 9999)}",
                "priceUnit": round(random.uniform(10.0, 1000.0), 2),
                "quantity": random.randint(1, 100)
            }
        }
        
        with self.client.post("/app/api/favourites", 
                            json=favourite_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "userId" in data or "productId" in data:
                        response.success()
                    else:
                        response.failure("Invalid favourite creation response")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(4)
    def favourite_get_user_favourites(self):
        """Use Case 3: Get user's favourites (wishlist view)"""
        user_id = random.randint(1, 10)
        with self.client.get(f"/app/api/favourites/user/{user_id}", catch_response=True) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) or "collection" in data:
                        response.success()
                    else:
                        response.failure("Invalid user favourites format")
                except:
                    response.failure("Invalid JSON response")
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(3)
    def favourite_update_favourite(self):
        """Use Case 4: Update favourite (wishlist management)"""
        favourite_id = random.randint(1, 10)
        favourite_data = {
            "userId": self.user_id,
            "productId": random.randint(1, 10)
        }
        
        with self.client.put(f"/app/api/favourites/{favourite_id}", 
                            json=favourite_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")

    @task(2)
    def favourite_remove_from_favourites(self):
        """Use Case 5: Remove from favourites (wishlist removal)"""
        favourite_id = random.randint(1, 10)
        with self.client.delete(f"/app/api/favourites/{favourite_id}", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"HTTP {response.status_code}")


class HighLoadUser(HttpUser):
    """High load user for stress testing"""
    wait_time = between(0.1, 0.5)
    weight = 1  # 1 in 10 users will be high load
    
    @task(20)
    def rapid_product_queries(self):
        """Stress test: Rapid product queries"""
        product_id = random.randint(1, 50)
        self.client.get(f"/app/api/products/{product_id}")
    
    @task(15)
    def rapid_user_queries(self):
        """Stress test: Rapid user queries"""
        usernames = ["testuser", "admin", "selimhorri", "amineladjimi", "omarderouiche"]
        username = random.choice(usernames)
        self.client.get(f"/app/api/users/username/{username}")
    
    @task(10)
    def rapid_collection_queries(self):
        """Stress test: Rapid collection queries"""
        endpoints = ["/app/api/products", "/app/api/users", "/app/api/orders", 
                    "/app/api/payments", "/app/api/shippings", "/app/api/favourites"]
        endpoint = random.choice(endpoints)
        self.client.get(endpoint)


class EcommerceWorkflowUser(HttpUser):
    """User that performs complete e-commerce workflows"""
    wait_time = between(2, 5)
    weight = 2  # 2 in 10 users will be workflow users
    
    def on_start(self):
        """Initialize workflow user"""
        self.workflow_data = {
            "user_id": random.randint(1, 10),
            "product_id": random.randint(1, 10),
            "order_id": None,
            "payment_id": None,
            "shipping_id": None
        }
    
    @task(3)
    def complete_purchase_workflow(self):
        """Complete purchase workflow: Browse -> Order -> Payment -> Shipping"""
        
        # 1. Browse products
        self.client.get("/app/api/products")
        
        # 2. Get specific product
        self.client.get(f"/app/api/products/{self.workflow_data['product_id']}")
        
        # 3. Create order
        order_data = {
            "orderDesc": f"Workflow Order {random.randint(1000, 9999)}",
            "orderFee": round(random.uniform(100.0, 500.0), 2),
            "cart": {
                "cartId": random.randint(1, 100),
                "userId": self.workflow_data["user_id"]
            }
        }
        
        with self.client.post("/app/api/orders", 
                            json=order_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                self.workflow_data["order_id"] = random.randint(1, 10)
        
        # 4. Create payment
        if self.workflow_data["order_id"]:
            payment_data = {
                "isPayed": True,
                "paymentStatus": "COMPLETED",
                "order": {
                    "orderId": self.workflow_data["order_id"],
                    "orderDesc": order_data["orderDesc"],
                    "orderFee": order_data["orderFee"]
                }
            }
            
            with self.client.post("/app/api/payments", 
                                json=payment_data, 
                                headers={"Content-Type": "application/json"},
                                catch_response=True) as response:
                if response.status_code == 200:
                    self.workflow_data["payment_id"] = random.randint(1, 10)
        
        # 5. Create shipping
        if self.workflow_data["order_id"]:
            shipping_data = {
                "shippingAddress": f"{random.randint(100, 999)} Workflow Street, Test City",
                "shippingStatus": "SHIPPED",
                "order": {
                    "orderId": self.workflow_data["order_id"],
                    "orderDesc": order_data["orderDesc"],
                    "orderFee": order_data["orderFee"]
                }
            }
            
            with self.client.post("/app/api/shippings", 
                               json=shipping_data, 
                               headers={"Content-Type": "application/json"},
                               catch_response=True) as response:
                pass  # No need to check response for shipping
    
    @task(2)
    def user_management_workflow(self):
        """User management workflow: Register -> Login -> Profile Update"""
        
        # 1. Create user
        user_data = {
            "firstName": f"WorkflowUser{random.randint(1000, 9999)}",
            "lastName": f"LastName{random.randint(1000, 9999)}",
            "email": f"workflow{random.randint(1000, 9999)}@example.com",
            "phone": f"+123456{random.randint(1000, 9999)}",
            "credential": {
                "username": f"workflowuser{random.randint(1000, 9999)}",
                "password": "hashed_password",
                "roleBasedAuthority": "ROLE_USER",
                "isEnabled": True
            }
        }
        
        with self.client.post("/app/api/users", 
                            json=user_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                # 2. Get user by username
                self.client.get(f"/app/api/users/username/{user_data['credential']['username']}")
                
                # 3. Update user
                user_data["firstName"] = f"Updated{user_data['firstName']}"
                with self.client.put(f"/app/api/users/{random.randint(1, 10)}", 
                                  json=user_data, 
                                  headers={"Content-Type": "application/json"},
                                  catch_response=True) as response:
                    pass
    
    @task(1)
    def product_management_workflow(self):
        """Product management workflow: Create -> Update -> Delete"""
        
        # 1. Create product
        product_data = {
            "productTitle": f"Workflow Product {random.randint(1000, 9999)}",
            "sku": f"WF{random.randint(1000, 9999)}",
            "priceUnit": round(random.uniform(50.0, 300.0), 2),
            "quantity": random.randint(10, 50),
            "categoryDto": {
                "categoryId": random.randint(1, 3),
                "categoryTitle": random.choice(["Electronics", "Clothing", "Books"])
            }
        }
        
        with self.client.post("/app/api/products", 
                            json=product_data, 
                            headers={"Content-Type": "application/json"},
                            catch_response=True) as response:
            if response.status_code == 200:
                product_id = random.randint(1, 10)
                
                # 2. Update product
                product_data["productTitle"] = f"Updated {product_data['productTitle']}"
                product_data["priceUnit"] = round(product_data["priceUnit"] * 1.1, 2)
                
                with self.client.put(f"/app/api/products/{product_id}", 
                                  json=product_data, 
                                  headers={"Content-Type": "application/json"},
                                  catch_response=True) as response:
                    pass
                
                # 3. Get updated product
                self.client.get(f"/app/api/products/{product_id}")