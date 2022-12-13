from sqlalchemy import Boolean, Column, Date, ForeignKey, Identity, Integer, LargeBinary, Numeric, String, Table, text
from sqlalchemy.orm import relationship
from database.db import Base
metadata = Base.metadata


class Account(Base):
    __tablename__ = 'account'
    __table_args__ = {'schema': 'Company'}

    account_id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    pass_ = Column('pass', String)
    permission = Column(Integer, nullable=False)

    customer = relationship('Customer', back_populates='account')
    employee = relationship('Employee', back_populates='account')


class CustomerGroup(Base):
    __tablename__ = 'customer_group'
    __table_args__ = {'schema': 'Company'}

    group_id = Column(Integer, primary_key=True)
    group_name = Column(String)
    debt_threshold = Column(Numeric)

    customer = relationship('Customer', back_populates='group')


class Goods(Base):
    __tablename__ = 'goods'
    __table_args__ = {'schema': 'Company'}

    goods_id = Column(Integer, primary_key=True)
    name = Column(String)
    categories = Column(String)
    color = Column(String)
    picture = Column(LargeBinary)
    descriptions = Column(String)
    stock = Column(Integer)
    vendor = Column(String)
    spectifications = Column(String)
    unit = Column(String)

    goods_in_order = relationship('GoodsInOrder', back_populates='goods')
    sale_info = relationship('SaleInfo', back_populates='goods')


class ManagerStaff(Base):
    __tablename__ = 'manager_staff'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(Integer, primary_key=True)

    employee = relationship('Employee', back_populates='manager')


class PersonMakeOrder(Base):
    __tablename__ = 'person_make_order'
    __table_args__ = {'schema': 'Company'}

    id = Column(Integer, primary_key=True)

    customer = relationship('Customer', back_populates='person_make_order')
    employee = relationship('Employee', secondary='Company.saler_staff', back_populates='person_make_order')
    order = relationship('Order', back_populates='person_make_order')


class Vehicle(Base):
    __tablename__ = 'vehicle'
    __table_args__ = {'schema': 'Company'}

    license_plate = Column(String, primary_key=True)

    inside_transport = relationship('InsideTransport', back_populates='vehicle')


class Customer(Base):
    __tablename__ = 'customer'
    __table_args__ = {'schema': 'Company'}

    customer_id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    phone_number = Column(String)
    address = Column(String)
    group_id = Column(ForeignKey('Company.customer_group.group_id'))
    cashier_id = Column(Integer)
    person_make_order_id = Column(ForeignKey('Company.person_make_order.id'))
    account_id = Column(ForeignKey('Company.account.account_id'))

    account = relationship('Account', back_populates='customer')
    group = relationship('CustomerGroup', back_populates='customer')
    person_make_order = relationship('PersonMakeOrder', back_populates='customer')
    order = relationship('Order', back_populates='customer')
    order_tracking = relationship('OrderTracking', back_populates='customer')
    payment = relationship('Payment', back_populates='customer')
    sale_info = relationship('SaleInfo', back_populates='customer')


class Employee(Base):
    __tablename__ = 'employee'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(Integer, primary_key=True)
    account_id = Column(ForeignKey('Company.account.account_id'))
    scope_of_work = Column(String)
    manager_id = Column(ForeignKey('Company.manager_staff.employee_id'))
    name = Column(String)

    account = relationship('Account', back_populates='employee')
    manager = relationship('ManagerStaff', back_populates='employee')
    person_make_order = relationship('PersonMakeOrder', secondary='Company.saler_staff', back_populates='employee')


class WarehouseStaff(Employee):
    __tablename__ = ' warehouse_staff'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(ForeignKey('Company.employee.employee_id'), primary_key=True)


class CashierStaff(Employee):
    __tablename__ = 'cashier_staff'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(ForeignKey('Company.employee.employee_id'), primary_key=True)

    payment = relationship('Payment', back_populates='cashier_staff')


class Debt(Customer):
    __tablename__ = 'debt'
    __table_args__ = {'schema': 'Company'}

    customer_id = Column(ForeignKey('Company.customer.customer_id'), primary_key=True)
    amount = Column(Numeric, nullable=False)
    personal_debt_threshold = Column(Numeric)


class DeliveryStaff(Employee):
    __tablename__ = 'delivery_staff'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(ForeignKey('Company.employee.employee_id'), primary_key=True)

    transport = relationship('Transport', uselist=False, back_populates='delivery_staff')


class DriverStaff(Employee):
    __tablename__ = 'driver_staff'
    __table_args__ = {'schema': 'Company'}

    employee_id = Column(ForeignKey('Company.employee.employee_id'), primary_key=True, index=True)

    inside_transport = relationship('InsideTransport', back_populates='driver_staff')


class Order(Base):
    __tablename__ = 'order'
    __table_args__ = {'schema': 'Company'}

    order_id = Column(Integer, primary_key=True)
    finished = Column(Boolean, nullable=False, server_default=text('false'))
    customer_id = Column(ForeignKey('Company.customer.customer_id'))
    note = Column(String)
    created_date = Column(Date)
    person_make_order_id = Column(ForeignKey('Company.person_make_order.id'))

    customer = relationship('Customer', back_populates='order')
    person_make_order = relationship('PersonMakeOrder', back_populates='order')
    goods_in_order = relationship('GoodsInOrder', back_populates='order')
    order_tracking = relationship('OrderTracking', back_populates='order')
    sale_info = relationship('SaleInfo', back_populates='order')


t_saler_staff = Table(
    'saler_staff', metadata,
    Column('employee_id', ForeignKey('Company.employee.employee_id'), primary_key=True),
    Column('person_make_order_id', ForeignKey('Company.person_make_order.id')),
    schema='Company'
)


class GoodsInOrder(Base):
    __tablename__ = 'goods_in_order'
    __table_args__ = {'schema': 'Company'}

    goods_id = Column(ForeignKey('Company.goods.goods_id'), primary_key=True, nullable=False)
    order_id = Column(ForeignKey('Company.order.order_id'), primary_key=True, nullable=False)
    amount = Column(Integer, nullable=False)

    goods = relationship('Goods', back_populates='goods_in_order')
    order = relationship('Order', back_populates='goods_in_order')


class OrderTracking(Base):
    __tablename__ = 'order_tracking'
    __table_args__ = {'schema': 'Company'}

    customer_id = Column(ForeignKey('Company.customer.customer_id'), primary_key=True, nullable=False)
    order_id = Column(ForeignKey('Company.order.order_id'), primary_key=True, nullable=False)
    date = Column(Date, primary_key=True, nullable=False)
    status = Column(Integer, nullable=False)

    customer = relationship('Customer', back_populates='order_tracking')
    order = relationship('Order', back_populates='order_tracking')


class Payment(Base):
    __tablename__ = 'payment'
    __table_args__ = {'schema': 'Company'}

    date = Column(Date, primary_key=True, nullable=False)
    customer_id = Column(ForeignKey('Company.customer.customer_id'), primary_key=True, nullable=False)
    cashier_staff_id = Column(ForeignKey('Company.cashier_staff.employee_id'), primary_key=True, nullable=False)
    amount = Column(Numeric)

    cashier_staff = relationship('CashierStaff', back_populates='payment')
    customer = relationship('Customer', back_populates='payment')


class SaleInfo(Base):
    __tablename__ = 'sale_info'
    __table_args__ = {'schema': 'Company'}

    receipt_id = Column(Integer, Identity(always=True, start=1, increment=1, minvalue=1, maxvalue=999, cycle=False, cache=1), primary_key=True)
    order_id = Column(ForeignKey('Company.order.order_id'))
    goods_id = Column(ForeignKey('Company.goods.goods_id'))
    customer_id = Column(ForeignKey('Company.customer.customer_id'))
    sale_date = Column(Date)
    amount = Column(Integer)
    unit_price = Column(Numeric)
    tax = Column(Numeric)
    total = Column(Numeric)

    customer = relationship('Customer', back_populates='sale_info')
    goods = relationship('Goods', back_populates='sale_info')
    order = relationship('Order', back_populates='sale_info')
    delivery_package = relationship('DeliveryPackage', back_populates='receipt')


class Transport(Base):
    __tablename__ = 'transport'
    __table_args__ = {'schema': 'Company'}

    transport_id = Column(Integer, primary_key=True)
    delivery_staff_id = Column(ForeignKey('Company.delivery_staff.employee_id'), nullable=False, unique=True)
    cur_position = Column(String)
    delivery_locations = Column(String)
    status = Column(Integer)
    delivery_time = Column(Date)

    delivery_staff = relationship('DeliveryStaff', back_populates='transport')
    delivery_package = relationship('DeliveryPackage', back_populates='transport')


class DeliveryPackage(Base):
    __tablename__ = 'delivery_package'
    __table_args__ = {'schema': 'Company'}

    receipt_id = Column(ForeignKey('Company.sale_info.receipt_id'), primary_key=True, nullable=False)
    transport_id = Column(ForeignKey('Company.transport.transport_id'), primary_key=True, nullable=False)
    mass_kg_ = Column('mass(kg)', String)
    delivery_status = Column(Integer)

    receipt = relationship('SaleInfo', back_populates='delivery_package')
    transport = relationship('Transport', back_populates='delivery_package')


class InsideTransport(Transport):
    __tablename__ = 'inside_transport'
    __table_args__ = {'schema': 'Company'}

    transport_id = Column(ForeignKey('Company.transport.transport_id'), primary_key=True)
    license_plate = Column(ForeignKey('Company.vehicle.license_plate'))
    driver_staff_id = Column(ForeignKey('Company.driver_staff.employee_id'))

    driver_staff = relationship('DriverStaff', back_populates='inside_transport')
    vehicle = relationship('Vehicle', back_populates='inside_transport')


class OutsideTransport(Transport):
    __tablename__ = 'outside_transport'
    __table_args__ = {'schema': 'Company'}

    transport_id = Column(ForeignKey('Company.transport.transport_id'), primary_key=True)
    outside_license_plate = Column(String, nullable=False)
    outside_driver_name = Column(String, nullable=False)
